//
//  TextScannerProtocol.swift
//  
//
//  Created by  Vladyslav Fil on 22.05.2023.
//

import VisionKit

public protocol TextScannerProtocol {
    func recognize(from scan: VNDocumentCameraScan)
    func recognize(from image: UIImage)
}
