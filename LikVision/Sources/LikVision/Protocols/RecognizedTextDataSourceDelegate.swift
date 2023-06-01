//
//  RecognizedTextDataSourceDelegate.swift
//  
//
//  Created by  Vladyslav Fil on 22.05.2023.
//

import Vision

public protocol RecognizedTextDataSourceDelegate: AnyObject {
    func extractText(from observations: [VNRecognizedTextObservation])
    init(onDidExtract: @escaping (String) -> Void)
}
