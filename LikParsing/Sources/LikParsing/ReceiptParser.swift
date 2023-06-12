//
//  ReceiptParser.swift
//  
//
//  Created by  Vladyslav Fil on 12.06.2023.
//

import Foundation

public protocol ReceiptParserProtocol {
    func parse(text: String) -> Receipt
}

public class ReceiptParser: ReceiptParserProtocol {
    public init() {}
    
    public func parse(text: String) -> Receipt {
        let shop = text.firstMatch(of: tovRegexDSL)?.output.1 ?? "Unknown"
        let date = text.firstMatch(of: dateRegex)?.output.1 ?? Date()
        let sum = text.firstMatch(of: sumRegex)?.output.1 ?? 0
        let products = text.matches(of: productRegex).compactMap {
            Product(
                name: "\($0.1)",
                amount: $0.2 ?? 1,
                amountType: $0.2 != nil ? .kg : .piece,
                price: $0.3 ?? $0.4,
                sum: $0.4
            )
        }
        
        return Receipt(
            shop: String(shop),
            date: date,
            sum: sum,
            products: products,
            text: text
        )
    }
}
