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

// flatMap: ((A) -> M<B>) -> (M<A>) -> M<B>

extension Parser {
    func flatMap<B>(_ f: @escaping (A) -> Parser<B>) -> Parser<B> {
        return Parser<B> { str -> B? in
            let original = str
            let matchA = self.run(&str)
            let parserB = matchA.map(f)
            guard let matchB = parserB?.run(&str) else {
                str = original
                return nil
            }
            return matchB
        }
    }
}

let northSouth = char.flatMap {
    $0 == "N" ? always(1.0)
        : $0 == "S" ? always(-1)
    : .never
}

//let eastWest = Parser<Double> { str in
//    guard
//        let cardinal = str.first,
//        cardinal == "E" || cardinal == "W"
//    else { return nil }
//    str.removeFirst(1)
//    return cardinal == "E" ? 1 : -1
//}

let eastWest = char.flatMap {
    $0 == "E" ? always(1.0)
    : $0 == "W" ? always(-1)
    : .never
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

parseLatLong("40.6782° N, 73.9442° W")

"40.6782° N, 73.9442° W"

let coord = double
    .flatMap { lat in
        literal("° ")
            .flatMap { _ in
                northSouth
                    .flatMap { latSign in
                        literal(", ")
                            .flatMap { _ in
                                double
                                    .flatMap { long in
                                        literal("° ")
                                            .flatMap { _ in
                                                eastWest
                                                    .map { longSign in
                                                        return Coordinate(
                                                            latitude: lat * latSign,
                                                            longitude: long * longSign
                                                        )
                                                    }
                                            }
                                    }
                            }
                    }
            }
    }

coord.run("40.6782° N, 73.9442° W")

// zip: (F<A>, F<B>) -> F<(A, B)>

func zip<A, B>(_ a: Parser<A>, _ b: Parser<B>) -> Parser<(A, B)> {
    return Parser<(A, B)> { str -> (A, B)? in
        let original = str
        guard
        let matchA = a.run(&str),
        let matchB = b.run(&str)
        else {
            str = original
            return nil
        }
        return (matchA, matchB)
    }
}

func zip<A, B, C>(
    _ a: Parser<A>,
    _ b: Parser<B>,
    _ c: Parser<C>
) -> Parser<(A, B, C)> {
    return zip(a, zip(b, c))
        .map { a, bc in (a, bc.0, bc.1) }
}

func zip<A, B, C, D>(
    _ a: Parser<A>,
    _ b: Parser<B>,
    _ c: Parser<C>,
    _ d: Parser<D>
) -> Parser<(A, B, C, D)> {
    return zip(a, b, zip(c, d))
        .map { a, b, cd in (a, b, cd.0, cd.1) }
}

func zip<A, B, C, D, E>(
    _ a: Parser<A>,
    _ b: Parser<B>,
    _ c: Parser<C>,
    _ d: Parser<D>,
    _ e: Parser<E>
) -> Parser<(A, B, C, D, E)> {
    return zip(a, b, c, zip(d, e))
        .map { a, b, c, de in (a, b, c, de.0, de.1) }
}

func zip<A, B, C, D, E, F>(
    _ a: Parser<A>,
    _ b: Parser<B>,
    _ c: Parser<C>,
    _ d: Parser<D>,
    _ e: Parser<E>,
    _ f: Parser<F>
) -> Parser<(A, B, C, D, E, F)> {
    return zip(a, b, c, d, zip(e, f))
        .map { a, b, c, d, ef in (a, b, c, d, ef.0, ef.1) }
}

func zip<A, B, C, D, E, F, G>(
    _ a: Parser<A>,
    _ b: Parser<B>,
    _ c: Parser<C>,
    _ d: Parser<D>,
    _ e: Parser<E>,
    _ f: Parser<F>,
    _ g: Parser<G>
) -> Parser<(A, B, C, D, E, F, G)> {
    return zip(a, b, c, d, e, zip(f, g))
        .map { a, b, c, d, e, fg in (a, b, c, d, e, fg.0, fg.1) }
}

func oneOf<A>(
    _ ps: [Parser<A>]
) -> Parser<A> {
    return Parser<A> { str in
        for p in ps {
            if let match = p.run(&str) {
                return match
            }
        }
        return nil
    }
}

enum Currency: String, CaseIterable {
    case usd = "$"
    case eur = "€"
    case gbp = "£"
    case uah = "₴"
}

struct Money {
    let currency: Currency
    let value: Double
}

let currency = oneOf(
    Currency.allCases.map { currency in literal(currency.rawValue).map { currency } }
)

let money = zip(currency, double).map(Money.init)

money.run("$200.5")
money.run("200.5")
money.run("₴200.5")

func prefix(while p: @escaping (Character) -> Bool) -> Parser<Substring> {
    return Parser<Substring> { str in
        let prefix = str.prefix(while: p)
        str.removeFirst(prefix.count)
        return prefix
    }
}

let zeroOrMoreSpaces = prefix(while: { $0 == " " })
    .map { _ in () }

let oneOrMoreSpaces = prefix(while: { $0 == " " })
    .flatMap { $0.isEmpty ? .never : always(()) }

let latitude = zip(double, literal("°"), oneOrMoreSpaces, northSouth)
    .map { lat, _, _, latSign in lat * latSign }
let longtitude = zip(double, literal("°"), oneOrMoreSpaces, eastWest)
    .map { long, _, _, longSign in long * longSign }

let coord2 = zip(zeroOrMoreSpaces, latitude, literal(","), oneOrMoreSpaces, longtitude)
    .map { _, lat, _, _, long in
        Coordinate(
            latitude: lat,
            longitude: long
        )
    }

coord2.run("40.6782° N, 73.9442° W")
coord2.run("   40.6782°   N,   73.9442° W")

func zeroOrMore<A>(
    _ p: Parser<A>,
    seperatedBy s: Parser<Void> = always(())
) -> Parser<[A]> {
    return Parser<[A]> { str in
        var rest = str
        var matches: [A] = []
        while let match = p.run(&str) {
            rest = str
            matches.append(match)
            if s.run(&str) == nil {
                return matches
            }
        }
        str = rest
        return matches
    }
}

zeroOrMore(money)
    .run("$42€43£44₴45")

zeroOrMore(money, seperatedBy: literal(","))
    .run("$42,€43,£44,₴45,")

let comaOrNewline = char
    .flatMap {
        $0 == "," ? always(())
        : $0 == "\n" ? always(())
        : .never
    }

zeroOrMore(money, seperatedBy: comaOrNewline)
    .run(
"""
$42,€43,£44,₴45
$42,€43,£44,₴45
$42,€43,£44,₴45
$42,€43,£44,₴45
$42,€43,£44,₴45
$42,€43,£44,₴45
"""
    )

enum Location: String, CaseIterable {
    case nyc = "New York City"
    case berlin
    case london
}

struct Race {
    let location: Location
    let entranceFee: Money
    let path: [Coordinate]
}

let location = oneOf(
    Location.allCases.map { location in literal(location.rawValue).map { location } }
)

let race: Parser<Race> = zip(
    location,
    literal(","),
    oneOrMoreSpaces,
    money,
    literal("\n"),
    zeroOrMore(coord2, seperatedBy: literal("\n"))
).map { location, _, _, entranceFee, _, path in
    Race(location: location, entranceFee: entranceFee, path: path)
}

let races: Parser<[Race]> = zeroOrMore(race, seperatedBy: literal("\n---\n"))

let upcomingRaces = """
New York City, $300
40.60248° N, 74.06433° W
40.61807° N, 74.02966° W
40.64953° N, 74.00929° W
40.67884° N, 73.98198° W
40.69894° N, 73.95701° W
40.72791° N, 73.95314° W
40.74882° N, 73.94221° W
40.75740° N, 73.95309° W
40.76149° N, 73.96142° W
40.77111° N, 73.95362° W
40.80260° N, 73.93061° W
40.80409° N, 73.92893° W
40.81432° N, 73.93292° W
40.80325° N, 73.94472° W
40.77392° N, 73.96917° W
40.77293° N, 73.97671° W
---
Berlin, €100
13.36015° N, 52.51516° E
13.33999° N, 52.51381° E
13.32539° N, 52.51797° E
13.33696° N, 52.52507° E
13.36454° N, 52.52278° E
13.38152° N, 52.52295° E
13.40072° N, 52.52969° E
13.42555° N, 52.51508° E
13.41858° N, 52.49862° E
13.40929° N, 52.48882° E
13.37968° N, 52.49247° E
13.34898° N, 52.48942° E
13.34103° N, 52.47626° E
13.32851° N, 52.47122° E
13.30852° N, 52.46797° E
13.28742° N, 52.47214° E
13.29091° N, 52.48270° E
13.31084° N, 52.49275° E
13.32052° N, 52.50190° E
13.34577° N, 52.50134° E
13.36903° N, 52.50701° E
13.39155° N, 52.51046° E
13.37256° N, 52.51598° E
---
London, £500
51.48205° N, 0.04283° E
51.47439° N, 0.02170° E
51.47618° N, 0.02199° E
51.49295° N, 0.05658° E
51.47542° N, 0.03019° E
51.47537° N, 0.03015° E
51.47435° N, 0.03733° E
51.47954° N, 0.04866° E
51.48604° N, 0.06293° E
51.49314° N, 0.06104° E
51.49248° N, 0.04740° E
51.48888° N, 0.03564° E
51.48655° N, 0.01830° E
51.48085° N, 0.02223° W
51.49210° N, 0.04510° W
51.49324° N, 0.04699° W
51.50959° N, 0.05491° W
51.50961° N, 0.05390° W
51.49950° N, 0.01356° W
51.50898° N, 0.02341° W
51.51069° N, 0.04225° W
51.51056° N, 0.04353° W
51.50946° N, 0.07810° W
51.51121° N, 0.09786° W
51.50964° N, 0.11870° W
51.50273° N, 0.13850° W
51.50095° N, 0.12411° W
"""

races.run(upcomingRaces)
