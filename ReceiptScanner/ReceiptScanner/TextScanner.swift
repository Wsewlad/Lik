//
//  TextScanner.swift
//  ReceiptScanner
//
//  Created by  Vladyslav Fil on 17.01.2023.
//

import Foundation
import VisionKit
import Vision

extension Array {
    public subscript(safeIndex index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }

        return self[index]
    }
}

protocol RecognizedTextDataSource: AnyObject {
    func addRecognizedText(recognizedText: [VNRecognizedTextObservation])
}

typealias ReceiptContentField = (name: String, amount: String, price: String)

// The information to fetch from a scanned receipt.
struct ReceiptContents {
    var name: String?
    var items = [ReceiptContentField]()
}

//MARK: - TextScanner
class TextScanner: ObservableObject {
    @Published var contents = ReceiptContents()
    
    private var textRecognitionRequest = VNRecognizeTextRequest()
    
    init() {
        self.setupRecognizeTextRequest()
    }
    
    func parseData(from scan: VNDocumentCameraScan) {
        DispatchQueue.global(qos: .userInitiated).async {
            for pageNumber in 0 ..< scan.pageCount {
                let image = scan.imageOfPage(at: pageNumber)
                self.processImage(image: image)
            }
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
                        self.addRecognizedText(recognizedText: requestResults)
                    }
                }
            }
        }
        
        //        textRecognitionRequest.supportedRecognitionLanguages()
        textRecognitionRequest.recognitionLanguages = ["uk-UA"]
        textRecognitionRequest.customWords = ["завжди", "з", "собою", "спрей", "антисептичний"]
        textRecognitionRequest.usesLanguageCorrection = true
        textRecognitionRequest.recognitionLevel = .accurate
    }
}

extension TextScanner: RecognizedTextDataSource {
        func addRecognizedText(recognizedText: [VNRecognizedTextObservation]) {
            let observations = recognizedText.sorted { $0.boundingBox.minY > $1.boundingBox.minY && $0.boundingBox.minX > $1.boundingBox.minX }
            
            var startParsing: Bool = false
            
            var currName: String?
            var currAmount: String?
            var currPrice: String?
            
            let maximumCandidates = 1
            for observation in observations {
                guard let candidate = observation.topCandidates(maximumCandidates).first else { continue }
                var text = candidate.string
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                let prev = observations[safeIndex: (observations.firstIndex(of: observation) ?? 1) - 1] ?? observation
                let prevTexLowercased = (prev.topCandidates(maximumCandidates).first?.string ?? "")
                    .replacingOccurrences(of: " ", with: "")
                    .lowercased()
                
                let curr = observation
                print(text, observation.boundingBox.minY.formatted(), prev.boundingBox.maxX < curr.boundingBox.minX ? curr.boundingBox.minX.formatted() : prev.boundingBox.maxX.formatted())
                
                if prevTexLowercased.contains("сума") {
                    return
                }
                
                if prevTexLowercased.starts(with: "чек") || prevTexLowercased.starts(with: "#чек") {
                    startParsing = true
                }
                
                guard startParsing else { continue }
    
                if let name = currName, let amount = currAmount, let price = currPrice {
                    contents.items.append((name: name, amount: amount, price: price))
                    currName = nil
                    currAmount = nil
                    currPrice = nil
                } else {
                    let converted = text
                        .replacingOccurrences(of: "[^0-9\\,\\.]+", with: "", options: .regularExpression)
                        .replacingOccurrences(of: ",", with: ".")
                    
                    if text.lowercased().contains("x") {
                        currAmount = text
                            .lowercased()
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                            .replacingOccurrences(of: ",", with: ".")
                        
                    } else if let _ = try? Float(converted, format: .number) {
                        currPrice = converted
                        
                    } else {
                        if let name = currName, let price = currPrice {
                            contents.items.append((name: name, amount: "шт", price: price))
                            currName = nil
                            currAmount = nil
                            currPrice = nil
                        }
                        currName = text
                    }
                }
            }
        }
}
