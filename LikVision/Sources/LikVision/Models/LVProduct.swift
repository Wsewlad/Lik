//
//  LVProduct.swift
//  
//
//  Created by  Vladyslav Fil on 22.05.2023.
//

import Foundation

public struct LVProduct: Equatable, Codable {
    public struct Id: Hashable, Codable {
        public var value: String
    }
    
    public init(
        id: Id,
        name: String,
        quantity: Double
    ) {
        self.id = id
        self.name = name
        self.quantity = quantity
    }
    
    public var id: Id
    public var name: String
    public var quantity: Double
}
