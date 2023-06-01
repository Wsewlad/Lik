//
//  MockTextExtractor.swift
//  
//
//  Created by  Vladyslav Fil on 22.05.2023.
//

import LikVision
import Vision
import XCTest

class MockTextExtractor: RecognizedTextDataSourceDelegate {
    
    // Paramethers to test
    var isExtractMethodCalled: Bool = false
    var concatenatedResult: String = ""
    let expectation: XCTestExpectation
    
    // Configurations
    var isConcatenatedResultNeeded: Bool
    
    required init(onDidExtract: @escaping (String) -> Void) {
        self.expectation = XCTestExpectation(description: "Default MockTextExtractor expectation.")
        isConcatenatedResultNeeded = false
    }
    
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
            concatenatedResult = observations.reduce("") {
                var text = $0
                text += "\n" + $1.topCandidates(1).first!.string
                
                return text
            }
        }
        
        expectation.fulfill()
    }
}
