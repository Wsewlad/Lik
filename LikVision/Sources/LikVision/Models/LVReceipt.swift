//
//  LVReceipt.swift
//  
//
//  Created by  Vladyslav Fil on 22.05.2023.
//

import Foundation

public struct LVReceipt: Equatable, Codable {
    public struct Id: Hashable, Codable {
        public var value: String
    }
    
    public init(
        id: Id,
        date: Date,
        products: [LVProduct],
        text: String
    ) {
        self.id = id
        self.date = date
        self.products = products
        self.text = text
    }
    
    public var id: Id
    public var date: Date
    public var products: [LVProduct]
    public var text: String
}
