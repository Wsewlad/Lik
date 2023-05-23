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
    @StateObject private var textScanner: TextScanner = .init()
    
    @State private var isCameraPresented: Bool = false
    @State private var isFileImporterPresented: Bool = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                receiptsListView
                
                buttonsView
            }
            .navigationBarTitle(" ", displayMode: .inline)
            .onAppear {
                guard textScanner.delegate == nil else { return }
                
                textScanner.delegate = ReceiptParser { receipt in
                    viewModel.addNewReceipt(receipt.asReceipt)
                }
            }
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
        .fileImporter(
            isPresented: $isFileImporterPresented,
            allowedContentTypes: [.png, .jpeg, .heic],
            onCompletion: fileImportResultAction(result:)
        )
        .sheet(isPresented: $isCameraPresented) {
            DocumentCamera(
                cancelAction: { isCameraPresented = false },
                resultAction: cameraResultAction(result:)
            )
        }
    }
}

//MARK: - Camera Result Action
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
}

//MARK: - fileImport Result Action
private extension RootScreen {
    func fileImportResultAction(result: Result<URL, Error>) {
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
