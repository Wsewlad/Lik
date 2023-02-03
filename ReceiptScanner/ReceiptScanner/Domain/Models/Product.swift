//
//  Product.swift
//  ReceiptScanner
//
//  Created by  Vladyslav Fil on 22.01.2023.
//

import Foundation

struct Product: Equatable, Codable {
    struct Id: Hashable, Codable {
        var value: String
    }
    
    var id: Id
    var name: String
    var quantity: Double?
    var price: Double
    var cost: Double
}
