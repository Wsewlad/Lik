//
//  RootViewModel.swift
//  Lik
//
//  Created by  Vladyslav Fil on 19.05.2023.
//

import Foundation
import LikVision
import UIKit
import Combine

enum Destination {
    case details(Receipt)
}

class RootViewModel: ObservableObject {
    @Published private(set) var receipts: [Receipt]
    @Published var isCameraPresented: Bool = false
    @Published var isFileImporterPresented: Bool = false
    
    @Published var destination: Destination?
    
    private(set) var textScanner: TextScanner
    private(set) var textExtractor: RecognizedTextDataSourceDelegate
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        receipts: [Receipt] = [],
        destination: Destination? = nil,
        textScanner: TextScanner = TextScanner(customWords: Array(kCustomWords)),
        textExtractor: RecognizedTextDataSourceDelegate = TextExtractor()
    ) {
        self.receipts = receipts
        self.destination = destination
        self.textScanner = textScanner
        
        self.textExtractor = textExtractor
        self.textExtractor.extractedTextPublisher
            .receive(on: RunLoop.main)
            .sink {
                print($0)
            } receiveValue: { text in
                print(text)
            }
            .store(in: &self.cancellables)

        self.textScanner.delegate = textExtractor
    }
    
    func addNewReceipt(_ newReceipt: Receipt) {
        receipts.append(newReceipt)
    }
}

//MARK: - View Methods
extension RootViewModel {
    func receiptDetailsButtonTapped(_ receipt: Receipt) {
        destination = .details(receipt)
    }
    
    func dismissReceiptDetailsButtonTapped() {
        destination = nil
    }
    
    func confirmEditButtonTapped() {
        guard case var .details(receipt) = self.destination
        else { return }
        
        guard let currentReceiptIndex = receipts.firstIndex(of: receipt)
        else { return }
        
        self.receipts[currentReceiptIndex] = receipt
    }
}

//MARK: - Camera Result Action
extension RootViewModel {
    func cameraResultAction(result: CameraResult) {
        switch result {
        case let .success(scan):
            textScanner.recognize(from: scan)
            
        case let .failure(error):
            // TODO: - handle error
            print(error.localizedDescription)
        }
        
        isCameraPresented = false
    }
}

//MARK: - fileImport Result Action
extension RootViewModel {
    func fileImportResultAction(result: Result<URL, Error>) {
        switch result {
        case let .success(url):
            guard url.startAccessingSecurityScopedResource(),
                  let imageData = try? Data(contentsOf: url),
                  let image = UIImage(data: imageData)
            else {
                print("Can't read file")
                // TODO: - handle error
                return
            }
            url.stopAccessingSecurityScopedResource()
            textScanner.recognize(from: image)
            
        case let .failure(error):
            // TODO: - handle error
            print(error.localizedDescription)
        }
    }
}
