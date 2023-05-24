//
//  RootScreen.swift
//  ReceiptScanner
//
//  Created by  Vladyslav Fil on 03.02.2023.
//

import SwiftUI
import Vision
import VisionKit
import LikVision

struct RootScreen: View {
    @StateObject private var viewModel = RootViewModel()

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                receiptsListView
                
                buttonsView
            }
            .navigationBarTitle(" ", displayMode: .inline)
        }
    }
}

//MARK: - Receipts View
private extension RootScreen {
    var receiptsListView: some View {
        List {
            ForEach(viewModel.receipts, id: \.id) { receipt in
                ReceiptView(receipt: receipt)
                    .padding(.bottom, viewModel.receipts.last == receipt ? 100 : 0)
            }
            .listRowInsets(.init(top: 15, leading: 16, bottom: 0, trailing: 16))
            .listRowSeparator(.hidden)
        }
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
    }
}

//MARK: - Buttons View
private extension RootScreen {
    var buttonsView: some View {
        Menu {
            Button {
                viewModel.isFileImporterPresented.toggle()
            } label: {
                Label("Open files", systemImage: "folder.fill")
                    .foregroundStyle(Color.blue)
            }
            Button {
                guard VNDocumentCameraViewController.isSupported
                else { print("Document scanning not supported"); return }
                viewModel.isCameraPresented.toggle()
            } label: {
                Label("Open camera", systemImage: "camera.viewfinder")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color.white, Color.blue)
            }
        } label: {
            PlusView()
        }
        .padding(25)
        .fileImporter(
            isPresented: $viewModel.isFileImporterPresented,
            allowedContentTypes: [.png, .jpeg, .heic],
            onCompletion: viewModel.fileImportResultAction(result:)
        )
        .sheet(isPresented: $viewModel.isCameraPresented) {
            DocumentCamera(
                cancelAction: { viewModel.isCameraPresented = false },
                resultAction: viewModel.cameraResultAction(result:)
            )
        }
    }
}
