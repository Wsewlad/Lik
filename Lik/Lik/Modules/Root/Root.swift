//
//  Root.swift
//  ReceiptScanner
//
//  Created by  Vladyslav Fil on 03.02.2023.
//

import SwiftUI
import ComposableArchitecture

struct Root: ReducerProtocol {
    struct State: Equatable {
        var receipts: [Receipt] = []
    }
    
    enum Action: Equatable {
        case newReceiptParsed(Receipt)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case let .newReceiptParsed(receipt):
                state.receipts.append(receipt)
                return .none
            }
        }
    }
}
