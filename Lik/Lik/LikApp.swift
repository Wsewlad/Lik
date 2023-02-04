//
//  LikApp.swift
//  Lik
//
//  Created by  Vladyslav Fil on 14.01.2023.
//

import SwiftUI
import ComposableArchitecture

@main
struct LikApp: App {
    var body: some Scene {
        WindowGroup {
            RootScreen(
                store: Store(
                    initialState: Root.State(),
                    reducer: Root()
                )
            )
        }
    }
}
