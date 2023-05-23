//
//  TextScanner.swift
//  ReceiptScanner
//
//  Created by  Vladyslav Fil on 17.01.2023.
//

import Foundation
import VisionKit
import Vision

public class TextScanner: ObservableObject, TextScannerProtocol {
    private var textRecognitionRequest = VNRecognizeTextRequest()
    private let customWords: [String]
    
    public var delegate: RecognizedTextDataSourceDelegate?
    
    public init(customWords: [String] = []) {
        self.customWords = customWords
        self.setupRecognizeTextRequest()
    }
}

//MARK: - Setup RecognizeTextRequest
extension TextScanner {
    private func setupRecognizeTextRequest() {
        textRecognitionRequest = VNRecognizeTextRequest { request, error in
            guard error == nil else { return }
            
            if let results = request.results, !results.isEmpty {
                if let observations = request.results as? [VNRecognizedTextObservation] {
                    DispatchQueue.main.async {
                        self.delegate?.parse(observations)
                    }
                }
            }
        }
        
        //        textRecognitionRequest.supportedRecognitionLanguages()
        textRecognitionRequest.usesLanguageCorrection = true
        textRecognitionRequest.recognitionLanguages = ["uk-UA"]
        textRecognitionRequest.customWords = customWords
        textRecognitionRequest.recognitionLevel = .accurate
    }
}

//MARK: - Parse
extension TextScanner {
    public func parseData(from scan: VNDocumentCameraScan) {
        DispatchQueue.global(qos: .userInitiated).async {
            for pageNumber in 0..<scan.pageCount {
                let image = scan.imageOfPage(at: pageNumber)
                self.performRecognitionRequest(image: image)
            }
        }
    }
    
    public func parseData(from image: UIImage) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.performRecognitionRequest(image: image)
        }
    }
}

//MARK: - Perform Image Recognition Request
extension TextScanner {
    private func performRecognitionRequest(image: UIImage) {
        guard let cgImage = image.cgImage else {
            print("Failed to get cgimage from input image")
            return
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([textRecognitionRequest])
        } catch {
            print(error)
        }
    }
}
