//
//  MarathonRaceParserUtf8.swift
//  ParsingPerformance
//
//  Created by  Vladyslav Fil on 09.02.2023.
//

import Foundation

private let northSouth = Parser<Substring.UTF8View, UTF8.CodeUnit>.first.flatMap {
    $0 == .init(ascii: "N") ? .always(1.0)
    : $0 == .init(ascii: "S") ? .always(-1)
    : .never
}

private let eastWest = Parser<Substring.UTF8View, UTF8.CodeUnit>.first.flatMap {
    $0 == .init(ascii: "E") ? .always(1.0)
    : $0 == .init(ascii: "W") ? .always(-1)
    : .never
}

private let zeroOrMoreSpacesUTF8 = Parser<Substring.UTF8View, Void>.prefix(" "[...].utf8).zeroOrMore()

private let latitude = Parser.double
    .skip(.prefix("°"[...].utf8))
    .skip(zeroOrMoreSpacesUTF8)
    .take(northSouth)
    .map(*)

private let longtitude = Parser.double
    .skip(.prefix("°"[...].utf8))
    .skip(zeroOrMoreSpacesUTF8)
    .take(eastWest)
    .map(*)

private let coord = latitude
    .skip(.prefix(","[...].utf8))
    .skip(zeroOrMoreSpacesUTF8)
    .take(longtitude)
    .map(Coordinate.init)

//coord.run("40.6782° N, 73.9442° W")
//coord.run("40.6782°   N,   73.9442° W")


private let currency = Parser<Substring.UTF8View, Currency>.oneOf(
    Currency.allCases.map { currency in Parser.prefix(currency.rawValue[...].utf8).map { currency } }
)

private let money = zip(currency, .double)
    .map(Money.init(currency:value:))

//money.run("$200.5")
//money.run("200.5")
//money.run("₴200.5")
private let city = Parser<Substring.UTF8View, City>.oneOf(
    City.allCases.map { city in Parser.prefix(city.rawValue[...].utf8).map { city } }
)

private let locationName = Parser<Substring.UTF8View, Substring.UTF8View>.prefix(while: { $0 != .init(ascii: ",") })

private let race = city
//    .map { String(Substring($0)) }
    .skip(.prefix(", "[...].utf8))
    .take(money)
    .skip(.prefix("\n"[...].utf8))
    .take(coord.zeroOrMore(seperatedBy: .prefix("\n"[...].utf8)))
    .map(Race.init(location:entranceFee:path:))

let racesUTF8 = race.zeroOrMore(seperatedBy: .prefix("\n---\n"[...].utf8))
