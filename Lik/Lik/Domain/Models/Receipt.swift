//
//  Receipt.swift
//  ReceiptScanner
//
//  Created by  Vladyslav Fil on 22.01.2023.
//

import Foundation
import LikVision

struct Receipt: Equatable, Codable {
    struct Id: Hashable, Codable {
        var value: String
    }
    
    var id: Id
    var date: Date
    var products: [Product]
}

extension LVReceipt {
    var asReceipt: Receipt {
        .init(
            id: .init(value: id.value),
            date: date,
            products: products.map { $0.asProduct }
        )
    }
}
