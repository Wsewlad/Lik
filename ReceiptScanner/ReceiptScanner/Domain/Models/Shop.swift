//
//  Shop.swift
//  ReceiptScanner
//
//  Created by  Vladyslav Fil on 22.01.2023.
//

import Foundation

struct Shop: Codable {
    struct Id: Hashable, Codable {
        var value: String
    }
    
    var id: Id
    var name: String
    var address: String
}
