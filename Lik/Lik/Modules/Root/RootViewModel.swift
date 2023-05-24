//
//  RootViewModel.swift
//  Lik
//
//  Created by  Vladyslav Fil on 19.05.2023.
//

import Foundation
import LikVision
import UIKit

class RootViewModel: ObservableObject {
    @Published private(set) var receipts: [Receipt] = []
    @Published var isCameraPresented: Bool = false
    @Published var isFileImporterPresented: Bool = false
    
    private(set) var textScanner: TextScanner
    
    init(textScanner: TextScanner = TextScanner()) {
        self.textScanner = textScanner
        
        self.textScanner.delegate = ReceiptParser { [weak self] receipt in
            self?.addNewReceipt(receipt.asReceipt)
        }
    }
    
    func addNewReceipt(_ newReceipt: Receipt) {
        receipts.append(newReceipt)
    }
}

//MARK: - Camera Result Action
extension RootViewModel {
    func cameraResultAction(result: CameraResult) {
        switch result {
        case let .success(scan):
            textScanner.parseData(from: scan)
            
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
            textScanner.parseData(from: image)
            
        case let .failure(error):
            // TODO: - handle error
            print(error.localizedDescription)
        }
    }
}
