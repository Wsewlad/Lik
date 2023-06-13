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
    Capture {
        /\d+/
        ZeroOrMore(/[,\.]+\d+/)
    } transform: { Double($0.replacing(",", with: ".")) ?? 0 }
}
let number2 = Regex {
    Capture {
        /\d+/
        ZeroOrMore(/[,\.\s]+\d+/)
    } transform: { Double($0.replacing(/[,\.\s]+/, with: ".")) ?? 0 }
}
let amountRegex = Regex {
    number2
    OneOrMore(" ")
    One(.any)
    OneOrMore(" ")
    number
}
.ignoresCase()

//MARK: - Price
let priceRegex = Regex {
    One(.whitespace)
    number
    OneOrMore(.whitespace)
    One(/\p{Letter}/)
    Anchor.endOfLine
}
.ignoresCase()

//MARK: - Product
let productNameRegex = Regex {
    Capture {
        OneOrMore(.reluctant) {
            CharacterClass(
                .anyOf("%',/"),
                .word,
                .digit,
                .whitespace
            )
        }
    }
}

let productRegex = Regex {
    Anchor.startOfLine
    productNameRegex
    ZeroOrMore(.whitespace)
    Optionally(amountRegex)
    ZeroOrMore(.whitespace)
    priceRegex
}
.ignoresCase()
