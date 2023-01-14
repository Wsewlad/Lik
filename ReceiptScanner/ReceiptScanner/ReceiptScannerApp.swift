//
//  ReceiptScannerApp.swift
//  ReceiptScanner
//
//  Created by  Vladyslav Fil on 14.01.2023.
//

import SwiftUI

@main
struct ReceiptScannerApp: App {
    @StateObject private var viewModel = AppViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .task {
                    await viewModel.requestDataScannerAccessStatus()
                }
        }
    }
}
