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
import SwiftUINavigation

struct RootScreen: View {
    @ObservedObject var model: RootViewModel

    var body: some View {
        TabView {
            NavigationStack {
                ZStack(alignment: .bottom) {
                    receiptsListView
                    
                    buttonsView
                }
                .navigationBarTitle("Receipts", displayMode: .inline)
            }
            .tabItem {
                Label("Receipts", systemImage: "cart")
            }
            .toolbar(.automatic, for: .tabBar)
            .toolbarBackground(Color.clear, for: .tabBar)
            
            Text("Stats")
                .tabItem {
                    Label("Stats", systemImage: "chart.pie")
                }
                .toolbar(.automatic, for: .tabBar)
                .toolbarBackground(Color.clear, for: .tabBar)
        }
    }
}

//MARK: - Receipts View
private extension RootScreen {
    var receiptsListView: some View {
        List {
            ForEach($model.receipts, id: \.id) { $receipt in
                ReceiptRowView(
                    receipt: receipt,
                    isLast: model.receipts.last == receipt
                ) {
                    model.destination = .details(receipt)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .listStyle(.insetGrouped)
//        .sheet(
//            unwrapping: $model.destination,
//            case: /Destination.details
//        ) { $receipt in
//            NavigationStack {
//                ReceiptDetailsView(receipt: $receipt)
//            }
//            .presentationDragIndicator(.visible)
//            .presentationDetents([.medium, .large])
//        }
            case: /Destination.details
        ) { $receipt in
            NavigationStack {
                ReceiptDetailsView(receipt: $receipt)
            }
            .presentationDragIndicator(.visible)
        }
    }
}

//MARK: - Buttons View
private extension RootScreen {
    var buttonsView: some View {
        HStack {
            Button {
                model.isFileImporterPresented.toggle()
            } label: {
                Label("Open file", systemImage: "folder.fill")
            }
            
            Button {
                guard VNDocumentCameraViewController.isSupported
                else { print("Document scanning not supported"); return }
                model.isCameraPresented.toggle()
            } label: {
                Label("Open camera", systemImage: "camera.fill")
            }
        }
        .buttonStyle(.borderedProminent)
        .padding(.bottom, 25)
        .fileImporter(
            isPresented: $model.isFileImporterPresented,
            allowedContentTypes: [.png, .jpeg, .heic],
            onCompletion: model.fileImportResultAction(result:)
        )
        .sheet(isPresented: $model.isCameraPresented) {
            DocumentCamera(
                cancelAction: { model.isCameraPresented = false },
                resultAction: model.cameraResultAction(result:)
            )
        }
    }
}

struct RootScreen_Previews: PreviewProvider {
    static var previews: some View {
        RootScreen(
            model: RootViewModel(
                receipts: [
                    .fake
                ]
            )
        )
    }
}
