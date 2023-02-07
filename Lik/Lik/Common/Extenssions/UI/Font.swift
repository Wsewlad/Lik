//
//  Font.swift
//  Lik
//
//  Created by  Vladyslav Fil on 07.02.2023.
//

import Foundation

import SwiftUI

public extension Font {

    static func body() -> Font {
        if #available(iOS 14.0, *) {
            return Font.custom("Baskerville-Bold", size: 17.0, relativeTo: .body)
        } else {
            return Font.custom("Baskerville-Bold", size: 17.0)
        }
    }
    static func callout() -> Font {
        if #available(iOS 14.0, *) {
            return Font.custom("Baskerville-Bold", size: 16.0, relativeTo: .callout)
        } else {
            return Font.custom("Baskerville-Bold", size: 16.0)
        }
    }
    static func subheadline() -> Font {
        if #available(iOS 14.0, *) {
            return Font.custom("Baskerville-Bold", size: 15.0, relativeTo: .subheadline)
        } else {
            return Font.custom("Baskerville-Bold", size: 15.0)
        }
    }
    static func caption() -> Font {
        Font.custom("Baskerville-Regular", size: 12.0)
    }
    static func caption2() -> Font {
        if #available(iOS 14.0, *) {
            return Font.custom("Baskerville-Bold", size: 12.0, relativeTo: .caption2)
        } else {
            return Font.custom("Baskerville-Bold", size: 12.0)
        }
    }
    static func largeTitle() -> Font {
        Font.custom("Baskerville-Bold", size: 32.0)
    }
    static func title() -> Font {
        Font.custom("Baskerville-Bold", size: 28.0)
    }
    static func title2() -> Font {
        if #available(iOS 14.0, *) {
            return Font.custom("Baskerville-Bold", size: 22.0, relativeTo: .title2)
        } else {
            return Font.custom("Baskerville-Bold", size: 22.0)
        }
    }
    static func title3() -> Font {
        if #available(iOS 14.0, *) {
            return Font.custom("Baskerville-SemiBold", size: 20.0, relativeTo: .title3)
        } else {
            return Font.custom("Baskerville-SemiBold", size: 20.0)
        }
    }
}
