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
    func testTextScanner_whenRecognizeFromUIImageMethodCalled_delegateParseMethodShouldBeCalled() throws {
        // Arrange
        let mockReceiptParser = MockTextExtractor(
            expectation: XCTestExpectation(description: "Call parse method.")
        )
        sut.delegate = mockReceiptParser
        
        let image = try XCTUnwrap(UIImage(named: "silpo-1", in: Bundle.module, compatibleWith: nil))
        
        // Act
        sut.recognize(from: image)
        
        // Assert
        wait(for: [mockReceiptParser.expectation], timeout: 10)
        XCTAssertTrue(mockReceiptParser.isExtractMethodCalled, "The delegate's parse method should be called.")
    }
}

//MARK: - TextScanner observations result without CustomWords configured
extension TextScannerTests {
    func testTextScanner_observationsResultWithoutCustomWordsConfigured_shouldBeTheSame() throws {
        // Arrange
        let mockReceiptParser = MockTextExtractor(
            expectation: XCTestExpectation(description: "Observations result without CustomWords"),
            isConcatenatedResultNeeded: true
        )
        sut.delegate = mockReceiptParser
        
        let image = try XCTUnwrap(UIImage(named: "silpo-1", in: Bundle.module, compatibleWith: nil))
        let expectedResult = ExpectedResultExampleSilpo1.extracted.rawValue
        
        // Act
        sut.recognize(from: image)
        
        // Assert
        wait(for: [mockReceiptParser.expectation], timeout: 20)
        XCTAssertNotEqual(mockReceiptParser.concatenatedResult.trimmingCharacters(in: .whitespacesAndNewlines), expectedResult, "The TextScanner observations result should not equal to expected one.")
    }
}


//MARK: - (silpo-1) TextScanner observations result with CustomWords configured
extension TextScannerTests {
    func testTextScanner_observationsResultWithCustomWordsConfigured_shouldBeTheSame() throws {
        // Arrange
        sut = TextScanner(customWords: Array(kCustomWords))
        
        let mockTextExtractor = MockTextExtractor(
            expectation: XCTestExpectation(description: "Observations result with CustomWords"),
            isConcatenatedResultNeeded: true
        )
        sut.delegate = mockTextExtractor
        
        let image = try XCTUnwrap(UIImage(named: "silpo-1", in: Bundle.module, compatibleWith: nil))
        let expectedResult = ExpectedResultExampleSilpo1.extracted.rawValue
        
        // Act
        sut.recognize(from: image)
        
        // Assert
        wait(for: [mockTextExtractor.expectation], timeout: 20)
        XCTAssertEqual(mockTextExtractor.concatenatedResult.trimmingCharacters(in: .whitespacesAndNewlines), expectedResult, "The TextScanner observations result should equal to expected one.")
    }
}

//extension TextScannerTests {
//    func testTextScannerSilpo2_observationsResultWithCustomWordsConfigured_shouldBeTheSame() throws {
//        // Arrange
//        sut = TextScanner(customWords: Array(kCustomWords))
//
//        let mockTextExtractor = MockTextExtractor(
//            expectation: XCTestExpectation(description: "Observations result with CustomWords"),
//            isConcatenatedResultNeeded: true
//        )
//        sut.delegate = mockTextExtractor
//
//        let image = try XCTUnwrap(UIImage(named: "silpo-2", in: Bundle.module, compatibleWith: nil))
//        let expectedResult = ExpectedResultExampleSilpo2.withCustomWordsConfigured.rawValue
//
//        // Act
//        sut.recognize(from: image)
//
//        // Assert
//        wait(for: [mockTextExtractor.expectation], timeout: 15)
//        XCTAssertEqual(mockTextExtractor.concatenatedResult, expectedResult, "The TextScanner observations result should equal to expected one.")
//    }
//}
