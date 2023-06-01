//
//  TextExtractorTests.swift
//  
//
//  Created by  Vladyslav Fil on 24.05.2023.
//

import XCTest
@testable import LikVision

final class TextExtractorTests: XCTestCase {
    
    var textScanner: TextScanner!
    
    override func setUpWithError() throws {
        textScanner = TextScanner(customWords: Array(kCustomWords))
    }
    
    override func tearDownWithError() throws {
        textScanner = nil
    }
}

//MARK: - silpo-1 receipt example
extension TextExtractorTests {
    func testTextExtractor_silpo1ReceiptExample_shouldEqualToExpected() throws {
        // Arrange
        let image = try XCTUnwrap(UIImage(named: "silpo-1", in: Bundle.module, compatibleWith: nil))
        let expectation = XCTestExpectation(description: "Did parse expectation")
        
        let strategy = Date.ParseStrategy(
            format: "\(day: .twoDigits)-\(month: .twoDigits)-\(year: .defaultDigits)",
            timeZone: .gmt
        )
        
        textScanner.delegate = TextExtractor(onDidExtract: { text in
            // Assert
            
            expectation.fulfill()
        })
        
        // Act
        textScanner.parseData(from: image)
        
        wait(for: [expectation], timeout: 15)
    }
}
