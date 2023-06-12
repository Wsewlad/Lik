//
//  RootViewModel.swift
//  Lik
//
//  Created by  Vladyslav Fil on 19.05.2023.
//

import Foundation
import LikVision
import LikParsing
import UIKit
import Combine
import Observation

enum Destination {
    case details(Receipt)
}

@Observable class RootViewModel {
    private(set) var receipts: [Receipt] = []
    var isCameraPresented: Bool = false
    var isFileImporterPresented: Bool = false
    
    var destination: Destination? = nil
    
    private(set) var textScanner: TextScanner = TextScanner(customWords: Array(kCustomWords))
    private(set) var textExtractor: RecognizedTextDataSourceDelegate = TextExtractor()
    private(set) var receiptParser: ReceiptParserProtocol = ReceiptParser()
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        receipts: [Receipt] = [],
        destination: Destination? = nil,
        textScanner: TextScanner = TextScanner(customWords: Array(kCustomWords)),
        textExtractor: RecognizedTextDataSourceDelegate = TextExtractor(),
        receiptParser: ReceiptParserProtocol = ReceiptParser()
    ) {
        self.receipts = receipts
        self.destination = destination
        self.textScanner = textScanner
        
        self.textExtractor = textExtractor
        self.receiptParser = receiptParser
        self.textExtractor.extractedTextPublisher
            .receive(on: RunLoop.main)
            .map {
                receiptParser.parse(text: $0)
            }
            .sink {
                print($0)
            } receiveValue: { receipt in
                self.receipts.append(receipt.asReceipt)
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
