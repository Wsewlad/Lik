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
        let products = text.matches(of: productRegex).map { match in
            Product(
                name: "\(match.output.1)",
                amount: match.output.2 ?? 1,
                amountType: match.output.2 != nil ? .kg : .piece,
                price: match.output.3 ?? match.output.4,
                sum: match.output.4
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
