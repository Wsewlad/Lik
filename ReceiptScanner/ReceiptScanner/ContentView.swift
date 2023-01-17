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
    @State private var recognizedText: String = ""
    
    var body: some View {
        switch viewModel.dataScannerAccessStatus {
        case .scannerAvailable:
            mainView
        case .cameraNotAvailable:
            Text("Camera isn't available")
        case .scannerNotAvailable:
            Text("This device doesn't support text scanning")
        case .notDetermined:
            Text("Requestion amera access")
        case .cameraAccessNotGranted:
            Text("Please provide access to the camera in settings")
        }
    }
    
    private var mainView: some View {
        VStack {
//            DataScannerView(
//                recognizedItems: $viewModel.recognizedItems,
//                recognizedDataTypes: [ viewModel.recognizedDataType ],
//                recognizesMultipleItems: viewModel.recognizesMultipleItems
//            )
            Text(recognizedText)
            
            Button(action: {
                guard VNDocumentCameraViewController.isSupported else { print("Document scanning not supported"); return }
                isCameraPresented.toggle()
                
            }) {
                Text("Open camera")
            }
            .sheet(isPresented: $isCameraPresented) {
                DocumentCamera(
                    cancelAction: { isCameraPresented = false },
                    resultAction: { result in
                        switch result {
                        case let .success(scan):
                            let extractedImages = TextScanner.extractImages(from: scan)
                            let processedText = TextScanner.recognizeText(from: extractedImages)
                            DispatchQueue.main.async {
                                self.recognizedText = processedText
                            }
                            
                        case let .failure(error):
                            print(error.localizedDescription)
                        }
                        
                        isCameraPresented = false
                    }
                )
            }
            
//            bottomContainerView
//                .onChange(of: viewModel.scanType) { _ in viewModel.recognizedItems = [] }
//                .onChange(of: viewModel.textContentType) { _ in viewModel.recognizedItems = [] }
//                .onChange(of: viewModel.recognizesMultipleItems) { _ in viewModel.recognizedItems = []}
        }
    }
    
    private var headerView: some View {
        VStack {
            HStack {
                Picker("Scan Type", selection: $viewModel.scanType) {
                    Text("Barcode").tag(ScanType.barcode)
                    Text("Text").tag(ScanType.text)
                }
                .pickerStyle(.segmented)
                
                Toggle("Scan multiple", isOn: $viewModel.recognizesMultipleItems)
                
                Spacer()
            }
            .padding()
            
            if viewModel.scanType == .text {
                Picker("Text content type", selection: $viewModel.textContentType) {
                    ForEach(viewModel.textContentTypes, id: \.0) { (title, textType) in
                        Text(title).tag(textType)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            Text(viewModel.headerText)
                .padding(.top)
        }
        .padding(.horizontal)
    }
    
    private var bottomContainerView: some View {
        VStack {
            headerView
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(viewModel.recognizedItems) { item in
                        switch item {
                        case .barcode(let barcode):
                            Text(barcode.payloadStringValue ?? "Unknown barcode")
                            
                        case .text(let text):
                            Text(text.transcript)
                            
                        @unknown default:
                            Text("Unknown")
                        }
                    }
                }
                .padding()
            }
            .frame(height: 200)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
