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
    
    @StateObject private var textScanner: TextScanner = .init()
    
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
            ScrollView {
                VStack {
                    HStack {
                        Text("Назва")
                        Spacer()
                        Text("Кількість")
                        Spacer()
                        Text("Ціна")
                    }
                    .bold()
                    .padding()
                    
                    Divider()
                    
                    ForEach(textScanner.contents.items, id: \.name) { item in
                        HStack {
                            Text(item.name)
                            Spacer()
                            Text(item.amount)
                            Spacer()
                            Text(item.price)
                        }
                        .padding()
                    }
                }
            }
            
            Button(action: {
                guard VNDocumentCameraViewController.isSupported
                else { print("Document scanning not supported"); return }
                
                isCameraPresented.toggle()
            }) {
                Text("Open camera")
            }
            .padding()
            .sheet(isPresented: $isCameraPresented) {
                DocumentCamera(
                    cancelAction: { isCameraPresented = false },
                    resultAction: { result in
                        switch result {
                        case let .success(scan):
                            textScanner.parseData(from: scan)

                        case let .failure(error):
                            print(error.localizedDescription)
                        }
                        
                        isCameraPresented = false
                    }
                )
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
