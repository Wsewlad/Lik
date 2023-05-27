//
//  ReceiptParser.swift
//  ReceiptScanner
//
//  Created by  Vladyslav Fil on 22.01.2023.
//

import Foundation
import Vision

public class ReceiptParser: RecognizedTextDataSourceDelegate {
    private var onDidParse: (LVReceipt) -> Void
    
    required public init(onDidParse: @escaping (LVReceipt) -> Void) {
        self.onDidParse = onDidParse
    }
    
    public func parse(_ observations: [VNRecognizedTextObservation]) {
        let sortedObservations = observations.sorted {
            let lhsMinY = $0.boundingBox.minY.lvRounded()
            let rhsMinY = $1.boundingBox.minY.lvRounded()
            let lhsMinX = $0.boundingBox.minX.lvRounded()
            let rhsMinX = $1.boundingBox.minX.lvRounded()
            
            return lhsMinY == rhsMinY ? lhsMinX < rhsMinX : lhsMinY > rhsMinY
        }

        let fullText = sortedObservations.reduce((text: "", prevMinY: 0.0, prevMinX: 0.0)) {
            var text = $0.text
            if $0.prevMinY == $1.boundingBox.minY.lvRounded() || $0.prevMinX < $1.boundingBox.minX.lvRounded() {
                text += "  " + $1.topCandidates(1).first!.string
            } else {
                text += "\n" + $1.topCandidates(1).first!.string
            }
            
            return (text, $1.boundingBox.minY.lvRounded(), $1.boundingBox.minX.lvRounded())
        }
        
        #if DEBUG
        print(fullText)
        #endif
        
        self.onDidParse(
            LVReceipt(
                id: .init(value: Date().formatted()),
                date: Date(),
                products: [
                
                ],
                text: fullText.text
            )
        )
    }
}
