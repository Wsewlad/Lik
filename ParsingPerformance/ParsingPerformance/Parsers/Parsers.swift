//
//  ParsingSreams.swift
//  stdin
//
//  Created by  Vladyslav Fil on 05.02.2023.
//

import Foundation

struct Parser<Input, Output> {
    let run: (inout Input) -> Output?
}

extension Parser {
    func run(_ input: Input) -> (match: Output?, rest: Input) {
        var input = input
        let match = self.run(&input)
        return (match, input)
    }
}

//MARK: - always, never
extension Parser {
    static func always(_ output: Output) -> Self {
        Self { _ in output }
    }

    static var never: Self {
        Self { _ in nil }
    }
}

//MARK: - int
extension Parser where Input == Substring, Output == Int {
    static let int = Self { input in
        let original = input

        var isFirstCharacter = true
        let intPrefix = input.prefix { character in
            defer { isFirstCharacter = false }
            return (character == "-" || character == "+") && isFirstCharacter || character.isNumber
        }

        guard let match = Int(intPrefix) else {
            input = original
            return nil
        }
        input.removeFirst(intPrefix.count)
        return match
    }
}

//MARK: - int (UnicodeScalarView)
extension Parser where Input == Substring.UnicodeScalarView, Output == Int {
    static let int = Self { input in
        let original = input

        var isFirstCharacter = true
        let intPrefix = input.prefix { c in
            defer { isFirstCharacter = false }
            return (c == "-" || c == "+") && isFirstCharacter || c.properties.numericType != nil
        }

        guard let match = Int(String(intPrefix)) else {
            input = original
            return nil
        }
        input.removeFirst(intPrefix.count)
        return match
    }
}

//MARK: - int (UTF8)
extension Parser where Input == Substring.UTF8View, Output == Int {
    static let int = Self { input in
        let original = input

        var isFirstCharacter = true
        let intPrefix = input.prefix { c in
            defer { isFirstCharacter = false }
            return (c == UTF8.CodeUnit(ascii: "-") || c == UTF8.CodeUnit(ascii: "+")) && isFirstCharacter || (UTF8.CodeUnit(ascii: "0")...UTF8.CodeUnit(ascii: "9")).contains(c)
        }

        guard let match = Int(String(Substring(intPrefix))) else {
            input = original
            return nil
        }
        input.removeFirst(intPrefix.count)
        return match
    }
}

//Parser.int.run("42 Hello World")

//MARK: - UInt64
extension Parser where Input == Substring, Output == UInt64 {
    static let uint64 = Self { input in
        let original = input

        var isFirstCharacter = true
        let intPrefix = input.prefix { character in
            defer { isFirstCharacter = false }
            return (character == "+") && isFirstCharacter || character.isNumber
        }

        guard let match = UInt64(intPrefix) else {
            input = original
            return nil
        }
        input.removeFirst(intPrefix.count)
        return match
    }
}


//MARK: - double
extension Parser where Input == Substring, Output == Double {
    static let double = Self { input in
        var sign: Double = 1.0
        let original = input
        if input.first == "-" {
            sign = -1
            input.removeFirst()
        }  else if input.first == "+" {
            input.removeFirst()
        }

        var decimalCount = 0
        let prefix = input.prefix { char in
            if char == "." || char == "," { decimalCount += 1 }
            return char.isNumber || ((char == "." || char == ",") && decimalCount <= 1)
        }

        guard let match = Double(prefix.replacing(",", with: "."))
        else {
            input = original
            return nil
        }
        input.removeFirst(prefix.count)
        return match * sign
    }
}

//MARK: - double (UTF8)
extension Parser where Input == Substring.UTF8View, Output == Double {
    static let double = Self { input in
        let original = input
        let sign: Double
        if input.first == .init(ascii: "-") {
            sign = -1
            input.removeFirst()
        } else if input.first == .init(ascii: "+") {
            sign = 1
            input.removeFirst()
        } else {
            sign = 1
        }
        
        var decimalCount = 0
        let prefix = input.prefix { c in
            if c == .init(ascii: ".") { decimalCount += 1 }
            return (.init(ascii: "0") ... .init(ascii: "9")).contains(c) || (c == .init(ascii: ".") && decimalCount <= 1)
        }
        
        guard let match = Double(String(Substring(prefix)))
        else {
            input = original
            return nil
        }
        
        input.removeFirst(prefix.count)
        return match * sign
    }
}

//Parser.double.run("42.3423 Hello world!")
//Parser.double.run("42,3423 Hello world!")

//MARK: - char
extension Parser
where
    Input: Collection,
    Input.SubSequence == Input,
    Output == Input.Element
{
    static var first: Self {
        .init { input in
            guard !input.isEmpty else { return nil }
            return input.removeFirst()
        }
    }
}



extension Parser where Input == Substring, Output == Character {
    static let char = first
//    static let char = Self { input in
//        guard !input.isEmpty else { return nil }
//        return input.removeFirst()
//    }
}

//MARK: - map
extension Parser {
    func map<NewOutput>(_ f: @escaping (Output) -> NewOutput) -> Parser<Input, NewOutput> {
        .init { input -> NewOutput? in
            self.run(&input).map(f)
        }
    }
}

//MARK: - flatMap
extension Parser {
    func flatMap<NewOutput>(_ f: @escaping (Output) -> Parser<Input, NewOutput>) -> Parser<Input, NewOutput> {
        return .init { input -> NewOutput? in
            let original = input
            let output = self.run(&input)
            let newParser = output.map(f)
            guard let newOutput = newParser?.run(&input) else {
                input = original
                return nil
            }
            return newOutput
        }
    }
}

//MARK: - zip
func zip<Input, Output1, Output2>(
    _ p1: Parser<Input, Output1>,
    _ p2: Parser<Input, Output2>
) -> Parser<Input, (Output1, Output2)> {
    .init { input -> (Output1, Output2)? in
        let original = input
        guard let output1 = p1.run(&input) else { return nil }
        guard let output2 = p2.run(&input)
        else {
            input = original
            return nil
        }
        return (output1, output2)
    }
}

//MARK: - oneOf
extension Parser {
    static func oneOf(_ ps: [Self]) -> Self {
        return .init { input in
            for p in ps {
                if let match = p.run(&input) {
                    return match
                }
            }
            return nil
        }
    }

    static func oneOf(_ ps: Self...) -> Self {
        self.oneOf(ps)
    }
}

//MARK: - zeroOrMore
extension Parser {
    func zeroOrMore(
        seperatedBy separator: Parser<Input, Void> = .always(())
    ) -> Parser<Input, [Output]> {
        Parser<Input, [Output]> { input in
            var rest = input
            var matches: [Output] = []
            while let match = self.run(&input) {
                rest = input
                matches.append(match)
                if separator.run(&input) == nil {
                    return matches
                }
            }
            input = rest
            return matches
        }
    }
}

//MARK: - prefix
extension Parser
where Input: Collection,
      Input.Element: Equatable,
      Input.SubSequence == Input,
      Output == Void {
    static func prefix(_ p: Input.SubSequence) -> Self {
        Self { input in
            guard input.starts(with: p) else { return nil }
            input.removeFirst(p.count)
            return ()
        }
    }
}

//MARK: - prefix while
extension Parser
where Input: Collection,
      Input.SubSequence == Input,
      Output == Input {
          static func prefix(while p: @escaping (Input.Element) -> Bool) -> Self {
        Self { input in
            let output = input.prefix(while: p)
            input.removeFirst(output.count)
            return output
        }
    }
}

//MARK: - prefix upTo, through
extension Parser
where Input: Collection,
      Input.SubSequence == Input,
      Input.Element: Equatable,
      Output == Input {
    static func prefix(upTo subsequence: Input) -> Self {
        Self { input in
            guard !subsequence.isEmpty else { return subsequence }
            let original = input
            while !input.isEmpty {
                if input.starts(with: subsequence) {
//                    return original[..<input.startIndex]
                    let output = original[..<input.startIndex]
                    if output.isEmpty {
                        input = original
                        return nil
                    }
                    return output
                }
                input.removeFirst()
            }
            input = original
            return nil
        }
    }

    static func prefix(through subsequence: Input) -> Self {
        Self { input in
            guard !subsequence.isEmpty else { return subsequence }
            let original = input
            while !input.isEmpty {
                if input.starts(with: subsequence) {
                    let index = input.index(input.startIndex, offsetBy: subsequence.count)
                    input = input[index...]
//                    return original[..<index]
                    let output = original[..<index]
                    if original[..<input.startIndex].isEmpty {
                        input = original
                        return nil
                    }
                    return output
                }
                input.removeFirst()
            }
            input = original
            return nil
        }
    }
}

extension Parser: ExpressibleByUnicodeScalarLiteral where Input == Substring, Output == Void {}
extension Parser: ExpressibleByExtendedGraphemeClusterLiteral where Input == Substring, Output == Void {}
extension Parser: ExpressibleByStringLiteral where Input == Substring, Output == Void {
    typealias StringLiteralType = String

    init(stringLiteral value: String) {
        self = .prefix(value[...])
    }
}

extension Parser where Input == Substring, Output == Substring {
    static func prefix<B>(upToParser p: Parser<Input, B>) -> Self {
        Self { input -> Substring? in
            guard !input.isEmpty
            else { return nil }

            var original = input
            var endIndex = original.startIndex
            while p.run(&input) == nil {
                if endIndex < original.endIndex {
                    endIndex = original.index(after: endIndex)
                } else {
                    input = original
                    return nil
                }
                input = input[endIndex...]
            }
            input = original[endIndex...]
//            return original[..<endIndex]
            
            let output = original[..<endIndex]
            if output.isEmpty {
                input = original
                return nil
            }
            return output
        }
    }

    static func prefix<B>(throughParser p: Parser<Input, B>) -> Self {
        Self { input -> Substring? in
            guard !input.isEmpty
            else { return nil }

            var original = input
            var endIndex = original.startIndex
            var output: B? = p.run(&input)
            while output == nil {
                if endIndex < original.endIndex {
                    endIndex = original.index(after: endIndex)
                } else {
                    input = original
                    return nil
                }
                input = input[endIndex...]
                output = p.run(&input)
            }
            guard let endIndex = original.range(of: input)?.lowerBound
            else { return nil }

//            return original[..<endIndex]
            
            let result = original[..<endIndex]
            if original[..<input.startIndex].isEmpty {
                input = original
                return nil
            }
            return result
        }
    }
}


//MARK: - skip
extension Parser {
    static func skip(_ p: Self) -> Parser<Input, Void> {
        p.map { _ in () }
    }
    
    func skip<OtherOutput>(_ p: Parser<Input, OtherOutput>) -> Self {
        zip(self, p).map { a, _ in a }
    }
    
    func take<NewOutput>(_ p: Parser<Input, NewOutput>) -> Parser<Input, (Output, NewOutput)> {
        zip(self, p)
    }
    
    func take<A>(_ p: Parser<Input, A>) -> Parser<Input, A> where Output == Void {
        zip(self, p).map { _, b in b }
    }
    
    func take<A, B, C>(_ p: Parser<Input, C>) -> Parser<Input, (A, B, C)> where Output == (A, B) {
        zip(self, p).map { ab, c in (ab.0, ab.1, c)  }
    }
}

extension Parser where Input == Substring, Output == Substring {
    static var rest: Self {
        Self { input in
            let rest = input
            input = ""
            return rest
        }
    }
}

extension Parser {
    static func optional<A>(_ parser: Parser<Input, A>) -> Self where Output == Optional<A> {
        .init { input in
            .some(parser.run(&input))
        }
    }
}

let temperature = Parser.int
    .skip("°F")
//temperature.run("100°F")

struct Product: Codable {
    struct Id: Hashable, Codable {
        var value: String
    }

    var id: Id
    var name: String
    var quantity: Double?
    var price: Double
    var cost: Double
}

extension Parser {
    func print() -> Self {
        self.map {
            Swift.print($0)
            return $0
        }
    }
}


extension Parser where Input == [String: String] {
    static func key(_ key: String, _ parser: Parser<Substring, Output>) -> Self {
        Self { dict in
            guard var value = dict[key]?[...]
            else { return nil }
            
            guard let output = parser.run(&value)
            else { return nil }
            
            dict[key] = value.isEmpty ? nil : String(value)
            return output
        }
    }
}

// /Applications/Xcode-14.2.0.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot

let xcodePath = Parser.key("IPHONE_SIMULATOR_ROOT", .prefix(through: ".app"))
let username = Parser.key("SIMULATOR_HOST_HOME", Parser<Substring, Void>.prefix("/Users/").take(.rest))

//xcodePath.take(username).run(ProcessInfo.processInfo.environment)
