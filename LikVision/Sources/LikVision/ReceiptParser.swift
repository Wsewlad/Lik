//
//  ReceiptParser.swift
//  ReceiptScanner
//
//  Created by  Vladyslav Fil on 22.01.2023.
//

import Foundation
import Vision

public class ReceiptParser: RecognizedTextDataSourceDelegate {
    var onDidParse: (LVReceipt) -> Void
    
    public init(onDidParse: @escaping (LVReceipt) -> Void) {
        self.onDidParse = onDidParse
    }
    
    public func parse(_ observations: [VNRecognizedTextObservation]) {
        let sortedObservations = observations.sorted {
            let lhsMinY = $0.boundingBox.minY.rounded()
            let rhsMinY = $1.boundingBox.minY.rounded()
            let lhsMinX = $0.boundingBox.minX.rounded()
            let rhsMinX = $1.boundingBox.minX.rounded()
            
            return lhsMinY == rhsMinY ? lhsMinX < rhsMinX : lhsMinY > rhsMinY
        }

        let fullText = sortedObservations.reduce((text: "", prevMinY: 0.0, prevMinX: 0.0)) {
            var text = $0.text
            if $0.prevMinY == $1.boundingBox.minY.rounded() || $0.prevMinX < $1.boundingBox.minX.rounded() {
                text += "  " + $1.topCandidates(1).first!.string
            } else {
                text += "\n" + $1.topCandidates(1).first!.string
            }
            
            return (text, $1.boundingBox.minY.rounded(), $1.boundingBox.minX.rounded())
        }
        
        #if DEBUG
        print(fullText)
        #endif
//        if let receipt = receiptParser.run(fullText.text[...]).match {
//            self.onDidParse(receipt)
//        } else {
//            self.onDidParse(
//                Receipt(
//                    id: .init(value: DateFormatter.monthDayYearTimeStyle.string(from: Date())),
//                    date: Date(),
//                    products: [],
//                    sum: 0,
//                    text: fullText.text
//                )
//            )
//        }
        
        
//        let maximumCandidates = 1
//        for observation in sortedObservations {
//            guard let candidate = observation.topCandidates(maximumCandidates).first else { continue }
//            let text = candidate.string
//                .trimmingCharacters(in: .whitespacesAndNewlines)
//
//            let prev = sortedObservations[safeIndex: (observations.firstIndex(of: observation) ?? 1) - 1] ?? observation
//            let prevTexLowercased = (prev.topCandidates(maximumCandidates).first?.string ?? "")
//                .replacingOccurrences(of: " ", with: "")
//                .lowercased()
//
//            let curr = observation
//
//            print(text, observation.boundingBox.minY.rounded(), prev.boundingBox.maxX < curr.boundingBox.minX ? curr.boundingBox.minX.rounded() : prev.boundingBox.maxX.rounded())
//        }
    }
}
