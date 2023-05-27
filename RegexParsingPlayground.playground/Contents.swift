import Foundation
import RegexBuilder
                      
var silpo1ReceiptText =
"""
ТОВ "СІЛЬПО-ФУД", магазин
м. Київ, вулиця Дорогожицька, будинок 2  ПН 407201926538
00001 Каса Островська 0.Л.  01
# ЧЕК N 31/2155/296  #
Хл300КиївхлСімейнНар  14,59 Б
Рул300КиївхлМакВ/ГВу  29,79 Б
КартопляКгБіла
1,  .758 X 7.59  13,34 Б
ЯБлукокгПіноваГолЧер
1,62 × 20,99  34,00 Б
Сос275ГлобМортадВсВи  57,99 Б
Смет350MiMiMilk201ve  39,99 Б
ПакфасовМайнДГе
2 X 0,22  0,44 Б
Незабаром здійсниться  #
ваша дитяча мрія.  #
#
B.B. 28349266  #
Бали в моб. додатку  #
СУМА  190,14 ГРН
ПЛВ Б  0,00%  0,00
КАРТКА  - .  190,14 ГРН  - - - .
ІЛЕНТ. ЕКВАЙРА  QR2929
ТЕрМТНАЛ  QR2029
кОМІСІЯ  0,00
ПлатІжна СИСТЕМА  OR
ВИД ОПЕРАЦІЧ  ОПЛАТА
ЕПЗ  XXXXXX4642
КОД ABT.  828939
BRN  301718978596
КАСИР:
ПЕРЖАТЕЛЬ ЕПЗ:
Восток  #
17-01-2023 18:40:18
0633713 0609622
ЗН КС00005950  МН 3999272824
ABOAAAVUAAAAABUAC69h
AAINWGIMKOoXPi/xtpA=
ФІСКАЛЬНИЙ ЧЕК  В Екселліо
"""

// ТОВ "СІЛЬПО-ФУД"
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

//if let match = silpo1ReceiptText.firstMatch(of: tovRegexDSL) {
//    print(match.output)
//} else {
//    print("TOV not found")
//}

// 17-01-2023 18:40:18
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

//if let match = silpo1ReceiptText.firstMatch(of: dateRegex) {
//    print(match.output)
//} else {
//    print("Date not found")
//}

// СУМА  190,14 ГРН
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


//if let match = silpo1ReceiptText.firstMatch(of: sumRegex) {
//    print(match[sum], type(of: match[sum]))
//} else {
//    print("Sum not found")
//}
//
//if silpo1ReceiptText.contains(/сільпо/.ignoresCase()) {
//    print("true")
//} else {
//    print("false")
//}


let input  = """
# ЧЕК N 31/2155/296  #
Хл300КиївхлСімейнНар  14,59 Б
Рул300КиївхлМакВ/ГВу  29,79 Б
КартопляКгБіла
1,  .758 X 7.59  13,34 Б
ЯБлукокгПіноваГолЧер
1,62 × 20,99  34,00 Б
Сос275ГлобМортадВсВи  57,99 Б
Смет350MiMiMilk201ve  39,99 Б
ПакфасовМайнДГе
2 X 0,22  0,44 Б
Незабаром здійсниться  #
ваша дитяча мрія.  #
"""
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

//let amountMatches = input.matches(of: amountRegex)
//print("Amount matches count: \(amountMatches.count)")
//for match in amountMatches {
//    print(match.output)
//}

let priceRegex = Regex {
    number
    OneOrMore(.whitespace)
    /A|Б/
}
.ignoresCase()

//let priceMatches = input.matches(of: priceRegex)
//print("Price matches count: \(priceMatches.count)")
//for match in priceMatches {
//    print(match.output)
//}

let productRegex = Regex {
    Capture {
        OneOrMore(/[\w\/]/, .reluctant)
    }
    ZeroOrMore(/[\s\n]/)
    ZeroOrMore(amountRegex)
    OneOrMore(.whitespace)
    priceRegex
}
.ignoresCase()

let productMatches = silpo1ReceiptText.matches(of: productRegex)
print("Product matches count: \(productMatches.count)")
for match in productMatches {
    print(match.output)
}
