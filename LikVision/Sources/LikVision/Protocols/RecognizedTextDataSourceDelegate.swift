//
//  RecognizedTextDataSourceDelegate.swift
//  
//
//  Created by  Vladyslav Fil on 22.05.2023.
//

import Vision

public protocol RecognizedTextDataSourceDelegate: AnyObject {
    func parse(_ observations: [VNRecognizedTextObservation])
    init(onDidParse: @escaping (LVReceipt) -> Void)
}
