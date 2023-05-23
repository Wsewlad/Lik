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
    var isParseMethodCalled: Bool = false
    let expectation = XCTestExpectation(description: "Call parse method.")
    
    func parse(_ observations: [VNRecognizedTextObservation]) {
        isParseMethodCalled = true
        expectation.fulfill()
    }
}
