//
//  CGFloat.swift
//  ReceiptScanner
//
//  Created by  Vladyslav Fil on 22.01.2023.
//

import Foundation

extension CGFloat {
    func rounded() -> Self {
        Foundation.round(self * 1000) / 1000
    }
    
    func formatted2f() -> String {
        String(format: "%.2f", self)
    }
}

extension Double {
    func formatted(points: Int) -> String {
        String(format: "%.\(points)f", self)
    }
}
