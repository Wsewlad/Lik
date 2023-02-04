//
//  TextScanner.swift
//  ReceiptScanner
//
//  Created by  Vladyslav Fil on 17.01.2023.
//

import Foundation
import VisionKit
import Vision

//MARK: - TextScanner
class TextScanner: ObservableObject {
    private var textRecognitionRequest = VNRecognizeTextRequest()
    var delegate: RecognizedTextDataSourceDelegate?
    
    init() {
        self.setupRecognizeTextRequest()
    }
    
    func parseData(from scan: VNDocumentCameraScan) {
        DispatchQueue.global(qos: .userInitiated).async {
            for pageNumber in 0..<scan.pageCount {
                let image = scan.imageOfPage(at: pageNumber)
                self.processImage(image: image)
            }
        }
    }
    
    func parseData(from image: UIImage) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.processImage(image: image)
        }
    }
    
    private func processImage(image: UIImage) {
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
    
    //MARK: - Setup RecognizeTextRequest
    private func setupRecognizeTextRequest() {
        textRecognitionRequest = VNRecognizeTextRequest { (request, error) in
            guard error == nil else { return }
            
            if let results = request.results, !results.isEmpty {
                if let requestResults = request.results as? [VNRecognizedTextObservation] {
                    DispatchQueue.main.async {
                        self.delegate?.parse(requestResults)
                    }
                }
            }
        }
        
        //        textRecognitionRequest.supportedRecognitionLanguages()
        textRecognitionRequest.usesLanguageCorrection = true
        textRecognitionRequest.recognitionLanguages = ["uk-UA"]
        textRecognitionRequest.customWords = Array(kCustomWords)
        textRecognitionRequest.recognitionLevel = .accurate
    }
}
