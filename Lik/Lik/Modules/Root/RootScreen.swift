//
//  RootScreen.swift
//  ReceiptScanner
//
//  Created by  Vladyslav Fil on 03.02.2023.
//

import SwiftUI
import ComposableArchitecture
import Vision
import VisionKit

struct RootScreen: View {
    let store: StoreOf<Root>
    
    @StateObject private var textScanner: TextScanner = .init()
    
    @State private var isCameraPresented: Bool = false
    @State private var isFileImporterPresented: Bool = false
    @State private var isPhotosPickerPresented: Bool = false

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationStack {
                VStack {
                    receiptsListView
                    
                    buttonsView
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        VStack {
                            Text("Лік")
                              .font(.title3())
                              .foregroundColor(.primaryText)
                        }
                    }
                }
                .onAppear {
                    guard textScanner.delegate == nil else { return }
                    textScanner.delegate = ReceiptParser { receipt in
                        viewStore.send(.newReceiptParsed(receipt))
                    }
                }
            }
        }
    }
}

//MARK: - Receipts View
private extension RootScreen {
    var receiptsListView: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ScrollView {
                VStack(spacing: 15) {
                    ForEach(viewStore.state.receipts, id: \.id) { receipt in
                        ReceiptView(receipt: receipt)
                    }
                }
                .padding([.horizontal, .bottom], 16)
            }
        }
    }
}

//MARK: - Buttons View
private extension RootScreen {
    var buttonsView: some View {
        VStack(spacing: 25) {
            Button("Open file") { isFileImporterPresented.toggle() }
                .fileImporter(isPresented: $isFileImporterPresented, allowedContentTypes: [.png, .jpeg, .heic], onCompletion: fileImportResult(result:))
            
            Button("Open camera") {
                guard VNDocumentCameraViewController.isSupported
                else { print("Document scanning not supported"); return }
                isCameraPresented.toggle()
            }
            .sheet(isPresented: $isCameraPresented) {
                DocumentCamera(
                    cancelAction: { isCameraPresented = false },
                    resultAction: cameraResultAction(result:)
                )
            }
        }
        .padding(.vertical, 25)
        .frame(maxWidth: .infinity)
        .background(.ultraThickMaterial)
    }
}

//MARK: - Actions
private extension RootScreen {
    func cameraResultAction(result: CameraResult) {
        switch result {
        case let .success(scan):
            textScanner.parseData(from: scan)

        case let .failure(error):
            print(error.localizedDescription)
        }
        
        isCameraPresented = false
    }
    
    func fileImportResult(result: Result<URL, Error>) {
        switch result {
        case let .success(url):
            guard url.startAccessingSecurityScopedResource(),
                  let imageData = try? Data(contentsOf: url),
                  let image = UIImage(data: imageData)
            else {
                print("Can't read file")
                return
            }
            url.stopAccessingSecurityScopedResource()
            textScanner.parseData(from: image)
            
        case let .failure(error):
            print(error.localizedDescription)
        }
    }
}
