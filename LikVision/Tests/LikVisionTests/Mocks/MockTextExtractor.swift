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
            concatenatedResult = observations.reduce("") {
                var text = $0
                text += "\n" + $1.topCandidates(1).first!.string
                
                return text
            }
        }
        
        expectation.fulfill()
    }
}
