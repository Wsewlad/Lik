//
//  MockReceiptParser.swift
//  
//
//  Created by  Vladyslav Fil on 22.05.2023.
//

import LikVision
import Vision
import XCTest

class MockReceiptParser: RecognizedTextDataSourceDelegate {
    // Paramethers to test
    var isParseMethodCalled: Bool = false
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
        
        print("MockReceiptParser init")
    }
    
    deinit {
        print("MockReceiptParser deinit")
    }
    
    func parse(_ observations: [VNRecognizedTextObservation]) {
        isParseMethodCalled = true
        
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
