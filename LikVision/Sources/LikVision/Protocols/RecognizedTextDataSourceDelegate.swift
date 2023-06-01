//
//  RecognizedTextDataSourceDelegate.swift
//  
//
//  Created by  Vladyslav Fil on 22.05.2023.
//

import Vision
import Combine

public protocol RecognizedTextDataSourceDelegate: AnyObject {
    func extractText(from observations: [VNRecognizedTextObservation])
    var extractedTextPublisher: AnyPublisher<String, Never> { get }
}
