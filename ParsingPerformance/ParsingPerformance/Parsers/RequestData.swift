//
//  RequestData.swift
//  ParsingPerformance
//
//  Created by  Vladyslav Fil on 06.02.2023.
//

import Foundation

struct RequestData {
    var body: Data?
    var headers: [String: Substring]
    var method: String?
    var pathComponents: ArraySlice<Substring>
    var queryItems: [(name: String, value: Substring)]
}

extension Parser where Input == RequestData, Output == Void {
    static func method(_ method: String) -> Self {
        .init { input in
            guard input.method?.uppercased() == method.uppercased()
            else { return nil }
            input.method = nil
            return ()
        }
    }
}

extension Parser where Input == RequestData {
    static func path(_ parser: Parser<Substring, Output>) -> Self {
        .init { input in
            guard var firstComponent = input.pathComponents.first
            else { return nil }
            
            let output = parser.run(&firstComponent)
            guard firstComponent.isEmpty
            else { return nil }
            
            input.pathComponents.removeFirst()
            return output
        }
    }
}

extension Parser where Input == RequestData {
    static func query(name: String, _ parser: Parser<Substring, Output>) -> Self {
        .init { input in
            guard var index = input.queryItems.firstIndex(where: { n, value in n == name })
            else { return nil }
            
            let original = input.queryItems[index].value
            guard let output = parser.run(&input.queryItems[index].value)
            else { return nil }
            
            guard input.queryItems[index].value.isEmpty
            else {
                input.queryItems[index].value = original
                return nil
            }
            input.queryItems.remove(at: index)
            return output
        }
    }
}

extension Parser where Input == RequestData, Output == Void {
    static let end = Self { input in
        guard input.pathComponents.isEmpty,
              input.method == nil
        else { return nil }
        
        input.body = nil
        input.queryItems = []
        input.headers = [:]
        return ()
    }
}

// GET /episodes/42?time=120
let episode = Parser.method("GET")
    .skip(.path("episodes"))
    .take(.path(.int))
    .take(.optional(.query(name: "time", .int)))
    .skip(.end)

let request = RequestData(
    body: nil,
    headers: ["User-Agent": "Safari"],
    method: "GET",
    pathComponents: ["episodes", "1", "comments"],
    queryItems: [(name: "time", value: "120")]
)

//episode.run(request)
enum Route {
    // GET .episodes/:int?time-:int
    case episodes(id: Int, time: Int?)
    
    // GET /episodes/:int/comments
    case episodesComments(id: Int)
}

let router = Parser.oneOf(
    Parser.method("GET")
        .skip(.path("episodes"))
        .take(.path(.int))
        .take(.optional(.query(name: "time", .int)))
        .skip(.end)
        .map(Route.episodes(id:time:)),

    Parser.method("GET")
        .skip(.path("episodes"))
        .take(.path(.int))
        .skip(.path("comments"))
        .skip(.end)
        .map(Route.episodesComments(id:))
)

//dump(
//router.run(request)
//)

