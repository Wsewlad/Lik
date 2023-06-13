//
//  MockTextExtractor.swift
//  
//
//  Created by  Vladyslav Fil on 22.05.2023.
//

import LikVision
import Vision
import XCTest
import Combine

class MockTextExtractor: RecognizedTextDataSourceDelegate {
    
    private var textSubject = PassthroughSubject<String, Never>()
    public var extractedTextPublisher: AnyPublisher<String, Never> {
        textSubject.eraseToAnyPublisher()
    }
    
    // Paramethers to test
    var isExtractMethodCalled: Bool = false
    var concatenatedResult: String = ""
    let expectation: XCTestExpectation
    
    // Configurations
    var isConcatenatedResultNeeded: Bool
    
    init(
        expectation: XCTestExpectation,
        isConcatenatedResultNeeded: Bool = false
    ) {
        self.expectation = expectation
        self.isConcatenatedResultNeeded = isConcatenatedResultNeeded
        
        print("MockTextExtractor init")
    }
    
    deinit {
        print("MockTextExtractor deinit")
    }
    
    func extractText(from observations: [VNRecognizedTextObservation]) {
        isExtractMethodCalled = true
        
        if isConcatenatedResultNeeded {
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
            
            concatenatedResult = result.text
        }
        
        expectation.fulfill()
    }
}
