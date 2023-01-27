import Foundation

struct Parser<Output> {
    let run: (inout Substring) -> Output?
}

extension Parser {
    func run(_ input: String) -> (match: Output?, rest: Substring) {
        var input = input[...]
        let match = self.run(&input)
        return (match, input)
    }
}





extension Parser where Output == Int {
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

Parser.int.run("42")
Parser.int.run("42 Hello World")
Parser.int.run("-42 Hello World")
Parser.int.run("--42 Hello World")
Parser.int.run("+42 Hello World")





extension Parser where Output == Double {
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
            if char == "." { decimalCount += 1 }
            return char.isNumber || (char == "." && decimalCount <= 1)
        }
        
        guard let match = Double(prefix)
        else {
            input = original
            return nil
        }
        input.removeFirst(prefix.count)
        return match * sign
    }
}

Parser.double.run("42")
Parser.double.run("42.3423423423")
Parser.double.run("42.3423423423 Hello world!")
Parser.double.run("42.4.5.6.3.2")
Parser.double.run(".42")
Parser.double.run("-42")
Parser.double.run("+42")





extension Parser where Output == Character {
    static let char = Self { input in
        guard !input.isEmpty else { return nil }
        return input.removeFirst()
    }
}

Parser.char.run("Hello")
Parser.char.run("")





extension Parser where Output == Void {
    static func prefix(_ p: String) -> Self {
        Self { input in
            guard input.hasPrefix(p) else { return nil }
            input.removeFirst(p.count)
            return ()
        }
    }
}

Parser.prefix("cat").run("cat dog")
Parser.prefix("cat").run("dog cat")
//
//func literal(_ literal: String) -> Parser<Void> {
//    return Parser<Void> { str in
//        guard str.hasPrefix(literal) else { return nil }
//        str.removeFirst(literal.count)
//        return ()
//    }
//}
//
//literal("cat").run("cat dog")
//literal("cat").run("dog cat")
//
//func always<A>(_ a: A) -> Parser<A> {
//    return Parser<A> { _ in a }
//}
//
//always("cat").run("dog")
//
//func never<A>() -> Parser<A> {
//    return Parser<A> { _ in nil }
//}
//extension Parser {
//    static var never: Parser {
//        Parser<A> { _ in nil }
//    }
//}
//
//extension Parser {
//    func map<B>(_ f: @escaping (A) -> B) -> Parser<B> {
//        return Parser<B> { str -> B? in
//            self.run(&str).map(f)
//        }
//    }
//}
//
//let even = int.map { $0 % 2 == 0 }
//even.run("123 Hello World")
//even.run("42 Hello World")
//
//let char = Parser<Character> { str in
//    guard !str.isEmpty else { return nil }
//    return str.removeFirst()
//}
//
//extension Parser {
//    func flatMap<B>(_ f: @escaping (A) -> Parser<B>) -> Parser<B> {
//        return Parser<B> { str -> B? in
//            let original = str
//            let matchA = self.run(&str)
//            let parserB = matchA.map(f)
//            guard let matchB = parserB?.run(&str) else {
//                str = original
//                return nil
//            }
//            return matchB
//        }
//    }
//}
//
//func zip<A, B>(_ a: Parser<A>, _ b: Parser<B>) -> Parser<(A, B)> {
//    return Parser<(A, B)> { str -> (A, B)? in
//        let original = str
//        guard
//        let matchA = a.run(&str),
//        let matchB = b.run(&str)
//        else {
//            str = original
//            return nil
//        }
//        return (matchA, matchB)
//    }
//}
//
//func zip<A, B, C>(
//    _ a: Parser<A>,
//    _ b: Parser<B>,
//    _ c: Parser<C>
//) -> Parser<(A, B, C)> {
//    return zip(a, zip(b, c))
//        .map { a, bc in (a, bc.0, bc.1) }
//}
//
//func zip<A, B, C, D>(
//    _ a: Parser<A>,
//    _ b: Parser<B>,
//    _ c: Parser<C>,
//    _ d: Parser<D>
//) -> Parser<(A, B, C, D)> {
//    return zip(a, b, zip(c, d))
//        .map { a, b, cd in (a, b, cd.0, cd.1) }
//}
//
//func zip<A, B, C, D, E>(
//    _ a: Parser<A>,
//    _ b: Parser<B>,
//    _ c: Parser<C>,
//    _ d: Parser<D>,
//    _ e: Parser<E>
//) -> Parser<(A, B, C, D, E)> {
//    return zip(a, b, c, zip(d, e))
//        .map { a, b, c, de in (a, b, c, de.0, de.1) }
//}
//
//func zip<A, B, C, D, E, F>(
//    _ a: Parser<A>,
//    _ b: Parser<B>,
//    _ c: Parser<C>,
//    _ d: Parser<D>,
//    _ e: Parser<E>,
//    _ f: Parser<F>
//) -> Parser<(A, B, C, D, E, F)> {
//    return zip(a, b, c, d, zip(e, f))
//        .map { a, b, c, d, ef in (a, b, c, d, ef.0, ef.1) }
//}
//
//func zip<A, B, C, D, E, F, G>(
//    _ a: Parser<A>,
//    _ b: Parser<B>,
//    _ c: Parser<C>,
//    _ d: Parser<D>,
//    _ e: Parser<E>,
//    _ f: Parser<F>,
//    _ g: Parser<G>
//) -> Parser<(A, B, C, D, E, F, G)> {
//    return zip(a, b, c, d, e, zip(f, g))
//        .map { a, b, c, d, e, fg in (a, b, c, d, e, fg.0, fg.1) }
//}
//
//func oneOf<A>(
//    _ ps: [Parser<A>]
//) -> Parser<A> {
//    return Parser<A> { str in
//        for p in ps {
//            if let match = p.run(&str) {
//                return match
//            }
//        }
//        return nil
//    }
//}
//
//enum Currency: String, CaseIterable {
//    case usd = "$"
//    case eur = "€"
//    case gbp = "£"
//    case uah = "₴"
//}
//
//struct Money {
//    let currency: Currency
//    let value: Double
//}
//
//let currency = oneOf(
//    Currency.allCases.map { currency in literal(currency.rawValue).map { currency } }
//)
//
//let money = zip(currency, double).map(Money.init)
//
//money.run("$200.5")
//money.run("200.5")
//money.run("₴200.5")
//
//func prefix(while p: @escaping (Character) -> Bool) -> Parser<Substring> {
//    return Parser<Substring> { str in
//        let prefix = str.prefix(while: p)
//        str.removeFirst(prefix.count)
//        return prefix
//    }
//}
//
//let zeroOrMoreSpaces = prefix(while: { $0 == " " })
//    .map { _ in () }
//
//let oneOrMoreSpaces = prefix(while: { $0 == " " })
//    .flatMap { $0.isEmpty ? .never : always(()) }
//
//struct Coordinate {
//    let latitude: Double
//    let longitude: Double
//}
//
//let northSouth = char.flatMap {
//    $0 == "N" ? always(1.0)
//        : $0 == "S" ? always(-1)
//    : .never
//}
//
//let eastWest = char.flatMap {
//    $0 == "E" ? always(1.0)
//    : $0 == "W" ? always(-1)
//    : .never
//}
//
//let latitude = zip(double, literal("°"), oneOrMoreSpaces, northSouth)
//    .map { lat, _, _, latSign in lat * latSign }
//let longtitude = zip(double, literal("°"), oneOrMoreSpaces, eastWest)
//    .map { long, _, _, longSign in long * longSign }
//
//let coord2 = zip(zeroOrMoreSpaces, latitude, literal(","), oneOrMoreSpaces, longtitude)
//    .map { _, lat, _, _, long in
//        Coordinate(
//            latitude: lat,
//            longitude: long
//        )
//    }
//
//coord2.run("40.6782° N, 73.9442° W")
//coord2.run("   40.6782°   N,   73.9442° W")
//
//func zeroOrMore<A>(
//    _ p: Parser<A>,
//    seperatedBy s: Parser<Void> = always(())
//) -> Parser<[A]> {
//    return Parser<[A]> { str in
//        var rest = str
//        var matches: [A] = []
//        while let match = p.run(&str) {
//            rest = str
//            matches.append(match)
//            if s.run(&str) == nil {
//                return matches
//            }
//        }
//        str = rest
//        return matches
//    }
//}
//
//zeroOrMore(money)
//    .run("$42€43£44₴45")
//
//zeroOrMore(money, seperatedBy: literal(","))
//    .run("$42,€43,£44,₴45,")
//
//let comaOrNewline = char
//    .flatMap {
//        $0 == "," ? always(())
//        : $0 == "\n" ? always(())
//        : .never
//    }
//
//zeroOrMore(money, seperatedBy: comaOrNewline)
//    .run(
//"""
//$42,€43,£44,₴45
//$42,€43,£44,₴45
//$42,€43,£44,₴45
//$42,€43,£44,₴45
//$42,€43,£44,₴45
//$42,€43,£44,₴45
//"""
//    )
//
//enum Location: String, CaseIterable {
//    case nyc = "New York City"
//    case berlin
//    case london
//}
//
//struct Race {
//    let location: Location
//    let entranceFee: Money
//    let path: [Coordinate]
//}
//
//let location = oneOf(
//    Location.allCases.map { location in literal(location.rawValue).map { location } }
//)
//
//let race: Parser<Race> = zip(
//    location,
//    literal(","),
//    oneOrMoreSpaces,
//    money,
//    literal("\n"),
//    zeroOrMore(coord2, seperatedBy: literal("\n"))
//).map { location, _, _, entranceFee, _, path in
//    Race(location: location, entranceFee: entranceFee, path: path)
//}
//
//let races: Parser<[Race]> = zeroOrMore(race, seperatedBy: literal("\n---\n"))
//
//let upcomingRaces = """
//New York City, $300
//40.60248° N, 74.06433° W
//40.61807° N, 74.02966° W
//40.64953° N, 74.00929° W
//40.67884° N, 73.98198° W
//40.69894° N, 73.95701° W
//40.72791° N, 73.95314° W
//40.74882° N, 73.94221° W
//40.75740° N, 73.95309° W
//40.76149° N, 73.96142° W
//40.77111° N, 73.95362° W
//40.80260° N, 73.93061° W
//40.80409° N, 73.92893° W
//40.81432° N, 73.93292° W
//40.80325° N, 73.94472° W
//40.77392° N, 73.96917° W
//40.77293° N, 73.97671° W
//---
//Berlin, €100
//13.36015° N, 52.51516° E
//13.33999° N, 52.51381° E
//13.32539° N, 52.51797° E
//13.33696° N, 52.52507° E
//13.36454° N, 52.52278° E
//13.38152° N, 52.52295° E
//13.40072° N, 52.52969° E
//13.42555° N, 52.51508° E
//13.41858° N, 52.49862° E
//13.40929° N, 52.48882° E
//13.37968° N, 52.49247° E
//13.34898° N, 52.48942° E
//13.34103° N, 52.47626° E
//13.32851° N, 52.47122° E
//13.30852° N, 52.46797° E
//13.28742° N, 52.47214° E
//13.29091° N, 52.48270° E
//13.31084° N, 52.49275° E
//13.32052° N, 52.50190° E
//13.34577° N, 52.50134° E
//13.36903° N, 52.50701° E
//13.39155° N, 52.51046° E
//13.37256° N, 52.51598° E
//---
//London, £500
//51.48205° N, 0.04283° E
//51.47439° N, 0.02170° E
//51.47618° N, 0.02199° E
//51.49295° N, 0.05658° E
//51.47542° N, 0.03019° E
//51.47537° N, 0.03015° E
//51.47435° N, 0.03733° E
//51.47954° N, 0.04866° E
//51.48604° N, 0.06293° E
//51.49314° N, 0.06104° E
//51.49248° N, 0.04740° E
//51.48888° N, 0.03564° E
//51.48655° N, 0.01830° E
//51.48085° N, 0.02223° W
//51.49210° N, 0.04510° W
//51.49324° N, 0.04699° W
//51.50959° N, 0.05491° W
//51.50961° N, 0.05390° W
//51.49950° N, 0.01356° W
//51.50898° N, 0.02341° W
//51.51069° N, 0.04225° W
//51.51056° N, 0.04353° W
//51.50946° N, 0.07810° W
//51.51121° N, 0.09786° W
//51.50964° N, 0.11870° W
//51.50273° N, 0.13850° W
//51.50095° N, 0.12411° W
//"""
//
//races.run(upcomingRaces)
//
