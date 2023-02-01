import Foundation
import Parsing


struct Product: Codable {
    struct Id: Hashable, Codable {
        var value: String
    }
    
    var id: Id
    var name: String
    var quantity: Double?
    var price: Double
    var cost: Double
}

let address = PrefixUpTo("ПН")

let pn = Parse {
    Skip {
        "ПН"
        Many { " " }
    }
    Digits()
}

let chequeNumber = Parse {
    Digits()
    Skip { "/" }
    Digits()
    Skip { "/" }
    Digits()
}

let price = Parse {
    Double.parser()
    Skip {
        Many { " " }
        OneOf { "Б"; "A" }
        Many { "\n" }
    }
}

let amount = Parse {
    Double.parser()
    Skip {
        Many { " " }
        OneOf { "x"; "X"; "х"; "Х" }
        Many { " " }
    }
    Double.parser()
}

let product1 = Parse {
    Consumed {
        Many(1...) {
            Not { amount }
            First()
        }
    }
    amount
    Skip { Many { " " } }
    price
}
.map { Product(id: .init(value: String($0)), name: String($0), quantity: $1.0, price: $1.1, cost: $2)
}

let product2 = Parse {
    Consumed {
        Many(1...) {
            Not { price }
            First()
        }
    }
    price
}
.map { Product(id: .init(value: String($0)), name: String($0), price: $1, cost: $1) }

let product3 = Parse {
    price
    PrefixUpTo(" ")
}
.map { Product(id: .init(value: String($1)), name: String($1), price: $0, cost: $0) }

var receipt = """
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
"""[...]

dump(
    try Parse {
        address
        pn
        Skip {
            Consumed {
                Many(1...) {
                  Not { chequeNumber }
                  First()
                }
              }
        }
        chequeNumber
        //Rest()//.map { String($0).replacing(",", with: ".")[...] }
//            .pipe {
//                Many {
//                    OneOf {
//                        product2
//                        product1
//                        product3
//                    }
//                }
//            }
    }.parse(&receipt)
)
//dump(receiptParser.run(receipt).match)
//print(receiptParser.run(receipt).rest)

