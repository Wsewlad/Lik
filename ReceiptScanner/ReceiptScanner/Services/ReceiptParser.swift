//
//  ReceiptParser.swift
//  ReceiptScanner
//
//  Created by  Vladyslav Fil on 22.01.2023.
//

import Foundation
import Vision

protocol RecognizedTextDataSourceDelegate: AnyObject {
    func parse(_ observations: [VNRecognizedTextObservation])
}

class ReceiptParser: RecognizedTextDataSourceDelegate {
    var onDidParse: (Receipt) -> Void
    
    init(onDidParse: @escaping (Receipt) -> Void) {
        self.onDidParse = onDidParse
    }
    
    func parse(_ observations: [VNRecognizedTextObservation]) {
        // TODO: - change id constructing logic
        var receipt: Receipt = .init(
            id: .init(value: DateFormatter().string(from: Date())),
            date: Date(),
            products: [],
            sum: 0
        )
        
        let observations = observations.sorted { $0.boundingBox.minY.rounded() > $1.boundingBox.minY.rounded() && $0.boundingBox.minX.rounded() > $1.boundingBox.minX.rounded() }
        
        var startParsing: Bool = false
        
        var currName: String?
        var currAmount: String?
        
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
            
            print(text, observation.boundingBox.minY.rounded(), prev.boundingBox.maxX < curr.boundingBox.minX ? curr.boundingBox.minX.rounded() : prev.boundingBox.maxX.rounded())
            
            if prevTexLowercased.contains("сума") {
                self.onDidParse(receipt)
                return
            }
            
            if prevTexLowercased.starts(with: "чек") || prevTexLowercased.starts(with: "#чек") || prevTexLowercased.starts(with: "hufk") {
                startParsing = true
            }
            
            guard startParsing else { continue }

            if let name = currName {
                if currAmount != nil || !(text.lowercased().contains("х") || text.lowercased().contains("x")) {
                    let price = text
                        .replacingOccurrences(of: "[^0-9\\,\\.]+", with: "", options: .regularExpression)
                        .replacingOccurrences(of: ",", with: ".")
                    
                    // TODO: - change id constructing logic
                    let product = Product(
                        id: .init(value: name),
                        name: name,
                        quantity: Double(currAmount?.split(separator: "х").first ?? ""),
                        price: Double(currAmount?.split(separator: "х").last ?? "") ?? Double(price) ?? 0,
                        cost: Double(price) ?? 0
                    )
                    receipt.products.append(product)
                    currName = nil
                    currAmount = nil
                } else {
                    currAmount = text
                        .lowercased()
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                        .replacingOccurrences(of: ",", with: ".")
                }
            } else {
                currName = text
            }
        }
        
//        self.onDidParse(receipt)
    }
}
