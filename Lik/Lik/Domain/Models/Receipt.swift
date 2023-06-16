//
//  Receipt.swift
//  ReceiptScanner
//
//  Created by  Vladyslav Fil on 22.01.2023.
//

import Foundation
import LikVision
import LikParsing
import UIKit

struct Receipt: Equatable, Codable {
    struct Id: Hashable, Codable {
        var value: String
    }
    
    var id: Id
    var shop: String
    var date: Date
    var sum: Double
    var products: [Product]
    var text: String
    var image: CodableImage?
}

//MARK: - asReceipt
extension LikParsing.Receipt {
    var asReceipt: Receipt {
        .init(
            id: .init(value: shop + date.description),
            shop: shop,
            date: date,
            sum: sum,
            products: products.map(\.asProduct),
            text: text
        )
    }
}

//MARK: - fake
extension Receipt {
    static var fake: Self {
        .init(
            id: .init(value: "test"),
            shop: "Сільпо",
            date: Date(),
            sum: 250,
            products: [
                .init(id: .init(value: "1"), name: "Хл300КиївхлСімейнНар", amount: 1, amountType: .piece, price: 25, sum: 25),
                .init(id: .init(value: "2"), name: "Рул300КиївхлМакВ/гВу", amount: 0.300, amountType: .piece, price: 25, sum: 25),
                .init(id: .init(value: "3"), name: "КартопляКгБіла", amount: 1.000, amountType: .kg, price: 25, sum: 25)
            ],
            text:
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
            17-91-2023 18:40:18
            0633713 0609622
            ЗН КС00005950  МН 3999272824
            ABOAAAVUAAAAABUAC69h
            AAINWGIMKOoXPi/xtpA=
            ФІСКАЛЬНИЙ ЧЕК  В Екселліо
            """
        )
    }
}
