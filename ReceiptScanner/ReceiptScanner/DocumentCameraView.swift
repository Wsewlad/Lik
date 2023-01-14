//
//  DocumentCameraView.swift
//  ReceiptScanner
//
//  Created by  Vladyslav Fil on 14.01.2023.
//

import Vision
import VisionKit
import SwiftUI

struct DocumentCameraView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        var vnDocumentCameraVC = VNDocumentCameraViewController()
        return vnDocumentCameraVC
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {
        uiViewController.delegate = context.coordinator
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}

//MARK: - Coordinator
extension DocumentCameraView {
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        
    }
}
