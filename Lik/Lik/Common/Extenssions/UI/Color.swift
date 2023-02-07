//
//  Color.swift
//  Lik
//
//  Created by  Vladyslav Fil on 07.02.2023.
//

import SwiftUI

private class BundleProvider {
    static let bundle = Bundle(for: BundleProvider.self)
}

public extension ShapeStyle where Self == Color {
    static var primaryText: Color { Color(#function) }
    static var secondaryText: Color { Color(#function) }
    static var secondaryBackground: Color { Color(#function) }
}
