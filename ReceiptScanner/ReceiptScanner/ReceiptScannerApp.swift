//
//  ReceiptScannerApp.swift
//  ReceiptScanner
//
//  Created by  Vladyslav Fil on 14.01.2023.
//

import SwiftUI
import ComposableArchitecture

@main
struct ReceiptScannerApp: App {
    @StateObject private var viewModel = AppViewModel()
    
    var body: some Scene {
        WindowGroup {
            RootScreen(
                store: Store(
                    initialState: Root.State(),
                    reducer: Root()
                )
            )
//            ContentView()
//                .environmentObject(viewModel)
//                .task {
//                    await viewModel.requestDataScannerAccessStatus()
//                }
        }
    }
}
