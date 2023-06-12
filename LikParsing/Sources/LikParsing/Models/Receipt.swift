//
//  Receipt.swift
//  
//
//  Created by  Vladyslav Fil on 12.06.2023.
//

import Foundation

public struct Receipt {
    public var shop: String
    public var date: Date
    public var sum: Double
    public var products: [Product]
    public var text: String
}
