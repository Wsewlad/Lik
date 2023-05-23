//
//  TextScannerProtocol.swift
//  
//
//  Created by  Vladyslav Fil on 22.05.2023.
//

import VisionKit

public protocol TextScannerProtocol {
    func parseData(from scan: VNDocumentCameraScan)
    func parseData(from image: UIImage)
}
