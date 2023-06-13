//
//  CGFloat.swift
//  
//
//  Created by  Vladyslav Fil on 24.05.2023.
//

import Foundation

public extension CGFloat {
    func lvRounded(points: Double = 2) -> Self {
        let multiplier = pow(10.0, points)
        return Double(Int(self * multiplier)) / multiplier
    }
} 
