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

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationStack {
                ZStack(alignment: .bottomTrailing) {
                    receiptsListView
                    
                    buttonsView
                }
                .navigationBarTitle(" ", displayMode: .inline)
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
            List {
                ForEach(viewStore.state.receipts, id: \.id) { receipt in
                    ReceiptView(receipt: receipt)
                        .padding(.bottom, viewStore.state.receipts.last == receipt ? 100 : 0)
                }
                .listRowInsets(.init(top: 15, leading: 16, bottom: 0, trailing: 16))
                .listRowSeparator(.hidden)
            }
            .scrollContentBackground(.hidden)
            .listStyle(.plain)
        }
    }
}

//MARK: - Buttons View
private extension RootScreen {
    var buttonsView: some View {
        Menu {
            Button {
                isFileImporterPresented.toggle()
            } label: {
                Label("Open files", systemImage: "folder.fill")
                    .foregroundStyle(Color.blue)
//                    .foregroundColor(.blue)
            }
            Button {
                guard VNDocumentCameraViewController.isSupported
                else { print("Document scanning not supported"); return }
                isCameraPresented.toggle()
            } label: {
                Label("Open camera", systemImage: "camera.viewfinder")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color.white, Color.blue)
            }
        } label: {
            PlusView()
        }
        .padding(25)
        .fileImporter(isPresented: $isFileImporterPresented, allowedContentTypes: [.png, .jpeg, .heic], onCompletion: fileImportResult(result:))
        .sheet(isPresented: $isCameraPresented) {
            DocumentCamera(
                cancelAction: { isCameraPresented = false },
                resultAction: cameraResultAction(result:)
            )
        }
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
