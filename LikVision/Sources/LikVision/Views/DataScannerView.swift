//
//  DataScannerView.swift
//  ReceiptScanner
//
//  Created by  Vladyslav Fil on 14.01.2023.
//

import VisionKit
import SwiftUI

public struct DataScannerView: UIViewControllerRepresentable {
    @Binding var recognizedItems: [RecognizedItem]
    
    var recognizedDataTypes: Set<DataScannerViewController.RecognizedDataType>
    var qualityLevel: DataScannerViewController.QualityLevel = .balanced
    var recognizesMultipleItems: Bool
    var isGuidanceEnabled: Bool = true
    var isHighlightingEnabled: Bool = true
    
    public func makeUIViewController(context: Context) -> DataScannerViewController {
        let dataScannerVC = DataScannerViewController(
            recognizedDataTypes: recognizedDataTypes,
            qualityLevel: qualityLevel,
            recognizesMultipleItems: recognizesMultipleItems,
            isPinchToZoomEnabled: true,
            isGuidanceEnabled: isGuidanceEnabled,
            isHighlightingEnabled: isHighlightingEnabled
        )
        return dataScannerVC
    }
    
    public func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        uiViewController.delegate = context.coordinator
        try? uiViewController.startScanning()
    }
    
    public static func dismantleUIViewController(_ uiViewController: DataScannerViewController, coordinator: Coordinator) {
        uiViewController.stopScanning()
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(recognizedItems: $recognizedItems)
    }
}

extension DataScannerView {
    public class Coordinator: NSObject, DataScannerViewControllerDelegate {
        @Binding var recognizedItems: [RecognizedItem]
        
        init(recognizedItems: Binding<[RecognizedItem]>) {
            self._recognizedItems = recognizedItems
        }
        
        public func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            self.recognizedItems.append(item)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }
}
