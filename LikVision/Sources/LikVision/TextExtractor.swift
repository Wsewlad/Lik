//
//  TextExtractor.swift
//  TextExtractor
//
//  Created by  Vladyslav Fil on 22.01.2023.
//

import Foundation
import Vision

public class TextExtractor: RecognizedTextDataSourceDelegate {
    private var onDidExtract: (String) -> Void
    
    required public init(onDidExtract: @escaping (String) -> Void) {
        self.onDidExtract = onDidExtract
    }
    
    /// Extracts text from a collection of recognized text observations and processes it.
    /// - Parameter observations: An array of VNRecognizedTextObservation objects representing the recognized text in the image.
    ///
    public func extractText(from observations: [VNRecognizedTextObservation]) {
        let sortedObservations = observations.sorted {
            let lhsMinY = $0.boundingBox.minY.lvRounded()
            let rhsMinY = $1.boundingBox.minY.lvRounded()
            let lhsMinX = $0.boundingBox.minX.lvRounded()
            let rhsMinX = $1.boundingBox.minX.lvRounded()

            return lhsMinY == rhsMinY ? lhsMinX < rhsMinX : lhsMinY > rhsMinY
        }

        let result = sortedObservations.reduce((text: "", prevMinY: 0.0, prevMinX: 0.0)) {
            var text = $0.text
            if $0.prevMinY == $1.boundingBox.minY.lvRounded() || $0.prevMinX < $1.boundingBox.minX.lvRounded() {
                text += "  " + $1.topCandidates(1).first!.string
            } else {
                text += "\n" + $1.topCandidates(1).first!.string
            }

            return (text, $1.boundingBox.minY.lvRounded(), $1.boundingBox.minX.lvRounded())
        }

        #if DEBUG
        print(result.text)
        #endif

        self.onDidExtract(result.text)
    }
}
