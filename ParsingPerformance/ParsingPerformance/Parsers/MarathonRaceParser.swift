//
//  MarathonRaceParser.swift
//  ParsingPerformance
//
//  Created by  Vladyslav Fil on 09.02.2023.
//

import Foundation

//MARK: - Coordinate
//"40.6782° N, 73.9442° W"

struct Coordinate {
    let latitude: Double
    let longitude: Double
}

private let northSouth = Parser.char.flatMap {
    $0 == "N" ? .always(1.0)
    : $0 == "S" ? .always(-1)
    : .never
}

private let eastWest = Parser.char.flatMap {
    $0 == "E" ? .always(1.0)
    : $0 == "W" ? .always(-1)
    : .never
}

let zeroOrMoreSpaces = Parser<Substring, Void>.prefix(" ").zeroOrMore()

private let latitude = Parser.double
    .skip("°")
    .skip(zeroOrMoreSpaces)
    .take(northSouth)
    .map(*)

private let longtitude = Parser.double
    .skip("°")
    .skip(zeroOrMoreSpaces)
    .take(eastWest)
    .map(*)

private let coord = latitude
    .skip(",")
    .skip(zeroOrMoreSpaces)
    .take(longtitude)
    .map(Coordinate.init)

//coord.run("40.6782° N, 73.9442° W")
//coord.run("40.6782°   N,   73.9442° W")

//MARK: - Currency
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

enum City: String, CaseIterable {
    case nyc = "New York City"
    case berlin = "Berlin"
    case london = "London"
}

private let city = Parser<Substring, City>.oneOf(
    City.allCases.map { city in Parser.prefix(city.rawValue[...]).map { city } }
)

private let currency = Parser<Substring, Currency>.oneOf(
    Currency.allCases.map { currency in Parser.prefix(currency.rawValue[...]).map { currency } }
)

private let money = zip(currency, .double)
    .map(Money.init(currency:value:))

//money.run("$200.5")
//money.run("200.5")
//money.run("₴200.5")

//MARK: - Races
struct Race {
    let location: City
    let entranceFee: Money
    let path: [Coordinate]
}

private let locationName = Parser<Substring, Substring>.prefix(while: { $0 != "," })

private let race = city
    //.map(String.init)
    .skip(", ")
    .take(money)
    .skip("\n")
    .take(coord.zeroOrMore(seperatedBy: "\n"))
    .map(Race.init(location:entranceFee:path:))

let races = race.zeroOrMore(seperatedBy: "\n---\n")

let upcomingRaces = """
New York City, $300
40.60248° N, 74.06433° W
40.61807° N, 74.02966° W
40.60248° N, 74.06433° W
40.61807° N, 74.02966° W
40.60248° N, 74.06433° W
40.61807° N, 74.02966° W
40.60248° N, 74.06433° W
40.61807° N, 74.02966° W
40.60248° N, 74.06433° W
40.61807° N, 74.02966° W
40.60248° N, 74.06433° W
40.61807° N, 74.02966° W
40.60248° N, 74.06433° W
40.61807° N, 74.02966° W
40.60248° N, 74.06433° W
40.61807° N, 74.02966° W
40.60248° N, 74.06433° W
40.61807° N, 74.02966° W
---
Berlin, €100
13.36015° N, 52.51516° E
13.33999° N, 52.51381° E
13.36015° N, 52.51516° E
13.33999° N, 52.51381° E
13.36015° N, 52.51516° E
13.33999° N, 52.51381° E
13.36015° N, 52.51516° E
13.33999° N, 52.51381° E
13.36015° N, 52.51516° E
13.33999° N, 52.51381° E
13.36015° N, 52.51516° E
13.33999° N, 52.51381° E
13.36015° N, 52.51516° E
13.33999° N, 52.51381° E
13.36015° N, 52.51516° E
13.33999° N, 52.51381° E
13.36015° N, 52.51516° E
13.33999° N, 52.51381° E
13.36015° N, 52.51516° E
13.33999° N, 52.51381° E
13.36015° N, 52.51516° E
13.33999° N, 52.51381° E
13.36015° N, 52.51516° E
13.33999° N, 52.51381° E
---
London, €700
13.36015° N, 52.51516° E
13.33999° N, 52.51381° E
13.36015° N, 52.51516° E
13.33999° N, 52.51381° E
13.36015° N, 52.51516° E
13.33999° N, 52.51381° E
13.36015° N, 52.51516° E
13.33999° N, 52.51381° E
13.36015° N, 52.51516° E
13.33999° N, 52.51381° E
13.36015° N, 52.51516° E
13.33999° N, 52.51381° E
13.36015° N, 52.51516° E
13.33999° N, 52.51381° E
13.36015° N, 52.51516° E
13.33999° N, 52.51381° E
13.36015° N, 52.51516° E
13.33999° N, 52.51381° E
13.36015° N, 52.51516° E
13.33999° N, 52.51381° E
13.36015° N, 52.51516° E
13.33999° N, 52.51381° E
13.36015° N, 52.51516° E
13.33999° N, 52.51381° E
"""

//race.run(upcomingRaces[...])
//races.run(upcomingRaces[...])
