//
//  ReceiptParser.swift
//  ParsingPerformance
//
//  Created by  Vladyslav Fil on 06.02.2023.
//

import Foundation

let address = Parser<Substring, Substring>.prefix(upTo: "ПН")
let pn = Parser
    .skip("ПН")
    .skip(zeroOrMoreSpaces)
    .take(.uint64)
let chequeNumber = Parser.int
    .skip("/")
    .take(.int)
    .skip("/")
    .take(.int)
let price = Parser.double
    .skip(zeroOrMoreSpaces)
    .skip(.oneOf("Б", "A"))
    .skip(Parser.prefix("\n").zeroOrMore())
let anount = Parser.double
    .skip(zeroOrMoreSpaces)
    .skip(.oneOf("x", "X", "х", "Х"))
    .skip(zeroOrMoreSpaces)
    .take(.double)
let sum = Parser
    .skip("СУМА")
    .skip(zeroOrMoreSpaces)
    .take(.double)
    .skip(zeroOrMoreSpaces)
    .skip("ГРН")

let product1 = Parser.prefix(upToParser: anount)
    .flatMap { $0.split(separator: " ").count > 1 ? .never : .always($0) }
    .take(anount)
    .skip(zeroOrMoreSpaces)
    .take(price)
    .map { (name, arg1, cost) in
        let (quantity, price) = arg1
        return Product(id: .init(value: String(name)), name: String(name), quantity: quantity, price: price, cost: cost)
    }


let product2 = Parser.prefix(upToParser: price)
    .flatMap { $0.split(separator: " ").count > 1 ? .never : .always($0) }
    .take(price)
    .map { (name, cost) in
        Product(id: .init(value: String(name)), name: String(name), price: cost, cost: cost)
    }

let product3 = price
    .take(.prefix(upTo: " "))
    .map { cost, name in
        Product(id: .init(value: String(name)), name: String(name), price: cost, cost: cost)
    }

let products = Parser.oneOf([product2, product3, product1]).zeroOrMore()

let receiptParser = Parser.skip(address)
    .skip(pn)
    .skip(.prefix(upToParser: chequeNumber))
    .skip(chequeNumber)
    .take(products)
    .skip(.prefix(upTo: "СУМА"))
    .take(sum)

let receipt = """
ТОВ "СІЛЬПО-ФУД", магазин
м. Київ, вулиця Дорогожицька, будинок 2  ПН 407201926538  01
00001 Каса островська О./.
H UFK N 31/2155/296
Хл300КиївхлСімейнНар  14,59 Б
29,79 Б
Рул300КиївхлМакв/гВу  КартопляКгБіла  758 Х 7.59  13,34 Б
ЯБлукокгПіноваГолЧер
1,62 Х 20,99  34,00 Б
Сос275ГлобМортадВсВу  57,99 Б
Смет350MiMiMilk201/e  39,99 Б
ПакФасовМайНДГЕ
2 X 0,22  0,44 Б  #
Незабаром здійсниться  #
ваша дитяча мрія.  #
#
B.B. 28349266  #
Бали в моб. додатку  СУМА  190,14 ГРН
ПДВ Б  0,00%  0,00
- .  - -
КАРТКА  190,14 ГРН
...  -- - -  QR2029
ІДЕНТ. ЕКВАЙРА  ТЕРМІНАЛ  QR2029
КОМСІЯ  0,00
ПЛАТІЖНА СИСТЕМА  OR
ВИД ОПЕРАЦІЇ  ОПЛАТА
ЕПЗ  XXXXXX4642  828939
КОД ABT.  RRN  301718978596
КАСИР:
ДЕРЖАТЕЛЬ ЕПЗ:  #
#
Восток  17-01-2023 18:40:18
0633713 0609622  ОН 3000272824
ЗН КС00005950  ABOAAAVUAAAAABUAC69h  AAINWgIMKooXPi/xtpA=
ФІСКАЛЬНИЙ ЧЕК  {Екселліо
"""

//dump(receiptParser.run(receipt[...]))
