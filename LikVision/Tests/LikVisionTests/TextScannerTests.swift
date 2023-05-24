//
//  TextScannerTests.swift
//  
//
//  Created by  Vladyslav Fil on 22.05.2023.
//

import XCTest
@testable import LikVision

final class TextScannerTests: XCTestCase {
    var sut: TextScanner!
    
    override func setUpWithError() throws {
        sut = TextScanner()
    }
    
    override func tearDownWithError() throws {
        sut = nil
    }
}

//MARK: - Delegate's parse method call
extension TextScannerTests {
    func testTextScanner_whenParseDataFromUIImageMethodCalled_delegateParseMethodShouldBeCalled() throws {
        // Arrange
        let mockReceiptParser = MockReceiptParser(
            expectation: XCTestExpectation(description: "Call parse method.")
        )
        sut.delegate = mockReceiptParser
        
        let image = try XCTUnwrap(UIImage(named: "silpo-1", in: Bundle.module, compatibleWith: nil))
        
        // Act
        sut.parseData(from: image)
        
        // Assert
        wait(for: [mockReceiptParser.expectation], timeout: 10)
        XCTAssertTrue(mockReceiptParser.isParseMethodCalled, "The delegate's parse method should be called.")
    }
}

//MARK: - TextScanner observations result without CustomWords configured
extension TextScannerTests {
    func testTextScanner_observationsResultWithoutCustomWordsConfigured_shouldBeTheSame() throws {
        // Arrange
        let mockReceiptParser = MockReceiptParser(
            expectation: XCTestExpectation(description: "Observations result without CustomWords"),
            isConcatenatedResultNeeded: true
        )
        sut.delegate = mockReceiptParser
        
        let image = try XCTUnwrap(UIImage(named: "silpo-1", in: Bundle.module, compatibleWith: nil))
        let expectedResult = ExpectedResultExampleSilpo1.withoutCustomWordsConfigured.rawValue
        
        // Act
        sut.parseData(from: image)
        
        // Assert
        wait(for: [mockReceiptParser.expectation], timeout: 10)
        XCTAssertEqual(mockReceiptParser.concatenatedResult, expectedResult, "The TextScanner observations result should equal to expected one.")
    }
}


//MARK: - TextScanner observations result with CustomWords configured
extension TextScannerTests {
    func testTextScanner_observationsResultWithCustomWordsConfigured_shouldBeTheSame() throws {
        // Arrange
        sut = TextScanner(customWords: Array(kCustomWords))
        
        let mockReceiptParser = MockReceiptParser(
            expectation: XCTestExpectation(description: "Observations result with CustomWords"),
            isConcatenatedResultNeeded: true
        )
        sut.delegate = mockReceiptParser
        
        let image = try XCTUnwrap(UIImage(named: "silpo-1", in: Bundle.module, compatibleWith: nil))
        let expectedResult = ExpectedResultExampleSilpo1.withCustomWordsConfigured.rawValue
        
        // Act
        sut.parseData(from: image)
        
        // Assert
        wait(for: [mockReceiptParser.expectation], timeout: 15)
        XCTAssertEqual(mockReceiptParser.concatenatedResult, expectedResult, "The TextScanner observations result should equal to expected one.")
    }
}
