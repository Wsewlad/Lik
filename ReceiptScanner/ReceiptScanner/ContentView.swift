//
//  ContentView.swift
//  ReceiptScanner
//
//  Created by  Vladyslav Fil on 14.01.2023.
//

import SwiftUI
import Vision
import VisionKit

struct ContentView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var isCameraPresented: Bool = false
    @State private var isFileImporterPresented: Bool = false
    
    @State private var receipts: [Receipt] = []
    @StateObject private var textScanner: TextScanner = .init()
    
    var body: some View {
        NavigationStack {
            switch viewModel.dataScannerAccessStatus {
            case .scannerAvailable:
                VStack {
                    receiptsListView
                    
                    buttonsView
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Receipts")
                .onAppear {
                    guard textScanner.delegate == nil else { return }
                    textScanner.delegate = ReceiptParser {
                        receipts.append($0)
                    }
                }
            case .cameraNotAvailable:
                Text("Camera isn't available")
            case .scannerNotAvailable:
                Text("This device doesn't support text scanning")
            case .notDetermined:
                Text("Requestion camera access")
            case .cameraAccessNotGranted:
                Text("Please provide access to the camera in settings")
            }
        }
    }
}

//MARK: - Receipts View
private extension ContentView {
    var receiptsListView: some View {
        ScrollView {
            VStack(spacing: 15) {
                ForEach(receipts, id: \.id) { receipt in
                    ReceiptView(receipt: receipt)
                }
            }
            .padding([.horizontal, .bottom], 16)
        }
    }
}

//MARK: - Buttons View
private extension ContentView {
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
private extension ContentView {
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
