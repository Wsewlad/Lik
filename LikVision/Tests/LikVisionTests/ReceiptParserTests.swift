//
//  ReceiptParserTests.swift
//  
//
//  Created by  Vladyslav Fil on 24.05.2023.
//

import XCTest
@testable import LikVision

final class ReceiptParserTests: XCTestCase {
    
    var textScanner: TextScanner!
    
    override func setUpWithError() throws {
        textScanner = TextScanner(customWords: Array(kCustomWords))
    }
    
    override func tearDownWithError() throws {
        textScanner = nil
    }
}

//MARK: - silpo-1 receipt example
extension ReceiptParserTests {
    func testReceiptParser_silpo1ReceiptExample_shouldEqualToExpected() throws {
        // Arrange
        let image = try XCTUnwrap(UIImage(named: "silpo-1", in: Bundle.module, compatibleWith: nil))
        let expectation = XCTestExpectation(description: "Did parse expectation")
        
        let strategy = Date.ParseStrategy(
            format: "\(day: .twoDigits)-\(month: .twoDigits)-\(year: .defaultDigits)",
            timeZone: .gmt
        )
        
        let expectedReceipt = LVReceipt(
            id: .init(value: "test"),
            date: try Date("17-01-2023", strategy: strategy),
            products: [
                .init(id: .init(value: "1"), name: "Хл300КиївхлСімейнНар", quantity: 1),
                .init(id: .init(value: "2"), name: "Рул300КиївхлМакВ/ГВу", quantity: 1),
                .init(id: .init(value: "3"), name: "КартопляКгБіла/ГВу", quantity: 1.758),
                .init(id: .init(value: "4"), name: "ЯБлукокгПіноваГолЧер", quantity: 1.62),
                .init(id: .init(value: "5"), name: "Сос275ГлобМортадВсВи", quantity: 1),
                .init(id: .init(value: "6"), name: "Смет350MiMiMilk201ve", quantity: 1),
                .init(id: .init(value: "7"), name: "ПакфасовМайнДГе", quantity: 2),
            ],
            text: ""
        )
        
        textScanner.delegate = ReceiptParser(onDidParse: { receipt in
            // Assert
            XCTAssertEqual(receipt.date, expectedReceipt.date, "Date does not equal to the expected")
            XCTAssertEqual(receipt.products.count, expectedReceipt.products.count, "Products count does not equal to the expected")
            
            if receipt.products.count == expectedReceipt.products.count {
                for productIndex in 0..<expectedReceipt.products.count {
                    XCTAssertEqual(
                        receipt.products[productIndex].name,
                        expectedReceipt.products[productIndex].name,
                        "Product \(productIndex)'s name does not equal to the expected"
                    )
                }
            }
            
            expectation.fulfill()
        })
        
        // Act
        textScanner.parseData(from: image)
        
        wait(for: [expectation], timeout: 15)
    }
}
