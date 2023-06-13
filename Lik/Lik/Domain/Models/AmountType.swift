//
//  AmountType.swift
//  Lik
//
//  Created by  Vladyslav Fil on 13.06.2023.
//

import Foundation
import LikParsing

enum AmountType: String, Codable {
    case kg
    case piece
    
    var label: String {
        switch self {
        case .kg: "кг"
        case .piece: "шт"
        }
    }
}

extension LikParsing.AmountType {
    var asAmountType: AmountType {
        .init(rawValue: self.rawValue) ?? .piece
    }
}
