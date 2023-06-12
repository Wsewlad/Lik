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
var silpo2ReceiptText =
"""
  ТОВ "СІЛЬПО-ФУД" kade
україна, м. Київ, Шевченківський р-н,  вул. дорогожицька,  ПН 407201926538
00056 Каса Попова 0. П.  91
# ЧЕК N 41/332/113  #
ПососьКгХребтГ/кКФ
0.536 X 179,00  95,94 Б
ПОБАЖАННЯ ВІД ГОСТЕЙ:
Цінуйте життя! Даруите  оБими рідним щодня!
B.B.  .28349266  #
Бали в моБ. додатку  #
ГУМА  95,94 ГРН
ПАВ Б  0,00%  - - . -  0,00
КАРТКА  95,94 ГРН
ІДЕНТ. ЕКВАЙРА  QR2029
ТЁРМІНАЛ  QR2029
КОМІСІЯ  0,00
ПЛАТІЖНА СИСТЕМА  QR
ВИД ОПЕРАЦІЇ  ОПЛАтА
ЕП3  XXXXXX4642  188942
КОД АВТ.  301921103195
RRN
КАСИР:
ДЕРЖАТЕЛЬ ЕПЗ:
Восток  9046119 0038396  10 др 283 241012)
ЗН КС00024319  ФН 3000921077
ABOAAANEAAAAABUADOYS
AACV/ABIKope/6mYmyo=
ФІСКАЛЬНИЙ ЧЕК  § Екселліо
"""
var atb1ReceiptText =
"""
  ТОВ "АТБ-маркет"
ми азин "Продукти-695"
м. Київ, Деснянський р-н,  пр. Лісовий, 28  indatomarket.com
email:
TAPSYA MINIS 0 800 500 415  ПЫ 304872104175
пол05 Чередник д. д.  01
Maca  5
лек 19343918, 2 946
батон 250 г' кулиничі нар  12,90 A
ізний половинка в/г гует
Сирок 90 г злагода  Дит яч
ми ватамінізований 13,5%  32,40 A
2 4 16,20
Пресерви 350 г Morven. 00  55,30 A
амедець філе в олії тут
Йогурт 310 г галичина Ви  29,90 A
ШМЯ - Злакя 2,2% пистака  130,50 ГРН
п08  20.00%  21,75
130,50 ГРН
- -  40384913
KOMICI9  0,00
ПЛАГТЖНА СИСТЕМА  Mastercard  Оплата
ВИД ОПЕРАЦТ!
ETT3  XXXXXXXXXXXXX055  886932
КОД АВТ.
RRN  301434942703
КАСир:  ПЕРЖАТЕЛЬ ЕПЗ:  ДЯКУЄМО ЗА ПОКУПКУ!
3521131 0510603  14-01-3023 12:58:38
3Н К500002842  ОН 3000766024
ABOAAAQRAAAAABUADag1
AAFKJWD7LIOLGIEIEh4=
мЕСКаЛЬНиЙ ЧЕК  eBi
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

if let match = silpo1ReceiptText.firstMatch(of: dateRegex) {
    print(match.output.1)
} else {
    print("Date not found")
}

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
    /\s|\n/
}
.ignoresCase()

//let priceMatches = input.matches(of: priceRegex)
//print("Price matches count: \(priceMatches.count)")
//for match in priceMatches {
//    print(match.output)
//}

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

let productMatches = atb1ReceiptText.matches(of: productRegex)
print("count: \(productMatches.count)")
for match in productMatches {
    var productString = "\(match.output.1) \t"
    
    if let amount = match.output.2 {
        productString += " \(amount)"
    }
    if let cost = match.output.3 {
        productString += " \(cost)"
    }
    productString += " \(match.output.4)"
    
    print(productString)
}
