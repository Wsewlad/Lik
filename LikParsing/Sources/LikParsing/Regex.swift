//
//  Regex.swift
//  
//
//  Created by  Vladyslav Fil on 12.06.2023.
//

import Foundation
import RegexBuilder

// MARK: - ТОВ
let tovRegex = /ТОВ\s*\"([\w\-]+)\"/

let word = OneOrMore(.word)
let tovRegexDSL = Regex {
    "тов"
    OneOrMore(.whitespace)
    "\""
    Capture {
        word
        "-"
        word
    }
    "\""
}.ignoresCase()

//MARK: - Date
let dateRegex = Regex {
    Capture(
        .date(
            format:
            """
            \(day: .twoDigits)-\(month: .twoDigits)-\(year: .defaultDigits)
             \(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .zeroBased)):\(minute: .twoDigits):\(second: .twoDigits)
            """,
            locale: .current, timeZone: .gmt
        )
    )
}

//MARK: - Sum
let sum = Reference(Double.self)
let sumRegex = Regex {
    "Сума"
    ZeroOrMore(.whitespace)
    Capture(as: sum) {
        OneOrMore(.digit)
        ","
        OneOrMore(.digit)
    } transform: { Double($0.replacing(",", with: "."))! }
    ZeroOrMore(.whitespace)
    "грн"
}
.ignoresCase()

//MARK: - Amout
let number = Regex {
    Capture { /\d+[,\.]*\d*/ } transform: { Double($0.replacing(",", with: "."))! }
}
let number2 = Regex {
    Capture { /\d+[,\.\s]*\d*/ } transform: { Double($0.replacing(/[,\.\s]+/, with: "."))! }
}
let amountRegex = Regex {
    number2
    OneOrMore(.whitespace)
    /X|×/
    OneOrMore(.whitespace)
    number
}
.ignoresCase()

//MARK: - Price
let priceRegex = Regex {
    number
    OneOrMore(.whitespace)
    /A|Б/
    /\s|\n/
}
.ignoresCase()

//MARK: - Product
let productRegex = Regex {
    Capture {
        OneOrMore(/[\w\d%',\s\n\/]/, .reluctant)
    }
    ZeroOrMore(/[\s\n]/)
    ZeroOrMore(amountRegex)
    OneOrMore(.whitespace)
    priceRegex
}
.ignoresCase()
