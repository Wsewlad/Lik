//
//  Product.swift
//  ReceiptScanner
//
//  Created by  Vladyslav Fil on 22.01.2023.
//

import Foundation
import LikVision

struct Product: Equatable, Codable {
    struct Id: Hashable, Codable {
        var value: String
    }
    
    var id: Id
    var name: String
    var quantity: Double
}

extension LVProduct {
    var asProduct: Product {
        .init(
            id: .init(value: id.value),
            name: name,
            quantity: quantity
        )
    }
}
