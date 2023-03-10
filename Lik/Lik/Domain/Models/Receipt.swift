//
//  Receipt.swift
//  ReceiptScanner
//
//  Created by  Vladyslav Fil on 22.01.2023.
//

import Foundation

struct Receipt: Equatable, Codable {
    struct Id: Hashable, Codable {
        var value: String
    }
    
    var id: Id
    var shop: Shop?
    var date: Date
    var products: [Product]
    var sum: Double
    var snapshotUrl: URL?
    var text: String
}
