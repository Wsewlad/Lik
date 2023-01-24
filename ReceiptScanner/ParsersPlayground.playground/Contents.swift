import Foundation

// 40.6782° N, 73.9442° W

struct Coordinate {
    let latitude: Double
    let longitude: Double
}
//
//func parseLatLong(_ str: String) -> Coordinate? {
//    let parts = str.split(separator: " ")
//    guard parts.count == 4 else { return nil }
//
//    guard
//        let lat = Double(parts[0].dropLast()),
//        let lon = Double(parts[2].dropLast())
//    else { return nil }
//    let latCard = parts[1].dropLast()
//    guard latCard == "N" || latCard == "S" else { return nil }
//    let lonCard = parts[3]
//    guard lonCard == "E" || lonCard == "W" else { return nil }
//    let latSign = latCard == "N" ? 1.0 : -1
//    let lonSign = lonCard == "E" ? 1.0 : -1
//    return Coordinate(latitude: lat * latSign, longitude: lon * lonSign)
//}

//print(parseLatLong("40.6782 N, 73.9442 W"))

struct Parser<A> {
//    let run: (String) -> A?
//    let run(String) -> (match: A?, rest: String)
//    let run: (inout String) -> A?
    let run: (inout Substring) -> A?
}

extension Parser {
    func run(_ str: String) -> (match: A?, rest: Substring) {
        var str = str[...]
        let match = self.run(&str)
        return (match, str)
    }
}

let int = Parser<Int> { str in
    let prefix = str.prefix(while: { $0.isNumber })
    guard let int = Int(prefix) else { return nil }
    str.removeFirst(prefix.count)
    return int
}

int.run("42")
int.run("42 Hello World")
int.run("Hello World")

let double = Parser<Double> { str in
    let prefix = str.prefix(while: { $0.isNumber || $0 == "." })
    guard let match = Double(prefix) else { return nil }
    str.removeFirst(prefix.count)
    return match
}

double.run("42")
double.run("42.3423423423")
double.run("42.3423423423 Hello world!")
double.run("42.4.5.6.3.2")


func literal(_ literal: String) -> Parser<Void> {
    return Parser<Void> { str in
        guard str.hasPrefix(literal) else { return nil }
        str.removeFirst(literal.count)
        return ()
    }
}

literal("cat").run("cat dog")
literal("cat").run("dog cat")

func always<A>(_ a: A) -> Parser<A> {
    return Parser<A> { _ in a }
}

always("cat").run("dog")

func never<A>() -> Parser<A> {
    return Parser<A> { _ in nil }
}
extension Parser {
    static var never: Parser {
        Parser<A> { _ in nil }
    }
}

(never() as Parser<Int>).run("dog")

Parser<Int>.never.run("dog")
 
// map: ((A) -> B) -> (F<A>) -> F<B>

// F<A> = Parser<A>
// map: ((A) -> B) -> (Parser<A>) -> Parser<B>

// map(id) = id

[1, 2, 3]
    .map { $0 }

Optional("Bob")
    .map { $0 }

// map: (Parser<A>, (A) -> B) -> Parser<B>

extension Parser {
    func map<B>(_ f: @escaping (A) -> B) -> Parser<B> {
        return Parser<B> { str -> B? in
            self.run(&str).map(f)
        }
    }
}

let even = int.map { $0 % 2 == 0 }
even.run("123 Hello World")
even.run("42 Hello World")

let char = Parser<Character> { str in
    guard !str.isEmpty else { return nil }
    return str.removeFirst()
}

//let northSouth = Parser<Double> { str in
//    guard
//        let cardinal = str.first,
//        cardinal == "N" || cardinal == "S"
//    else { return nil }
//    str.removeFirst(1)
//    return cardinal == "N" ? 1 : -1
//}

let northSouth = char.map {
    $0 == "N" ? always(1.0)
    : $0 == "S" ? always(-1)
    : never()
}

let eastWest = Parser<Double> { str in
    guard
        let cardinal = str.first,
        cardinal == "E" || cardinal == "W"
    else { return nil }
    str.removeFirst(1)
    return cardinal == "E" ? 1 : -1
}

func parseLatLong(_ str: String) -> Coordinate? {
    var str = str[...]
    
    guard let lat = double.run(&str),
          literal("° ").run(&str) != nil,
          let latSign = northSouth.run(&str),
          literal(", ").run(&str) != nil,
          let long = double.run(&str),
          literal("° ").run(&str) != nil,
          let longSign = eastWest.run(&str)
    else { return nil }
    
    return Coordinate(
        latitude: lat * latSign,
        longitude: long * longSign
    )
}

print(parseLatLong("40.6782° N, 73.9442° W"))
