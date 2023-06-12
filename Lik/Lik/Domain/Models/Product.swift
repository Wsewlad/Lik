//
//  Product.swift
//  ReceiptScanner
//
//  Created by  Vladyslav Fil on 22.01.2023.
//

import Foundation
import LikParsing

struct Product: Equatable, Codable {
    struct Id: Hashable, Codable {
        var value: String
    }
    
    var id: Id
    var name: String
    var amount: Double
}

extension LikParsing.Product {
    var asProduct: Product {
        .init(
            id: .init(value: name),
            name: name,
            amount: amount
        )
    }
}
