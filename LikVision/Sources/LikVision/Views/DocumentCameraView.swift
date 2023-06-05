//
//  DocumentCameraView.swift
//  ReceiptScanner
//
//  Created by  Vladyslav Fil on 14.01.2023.
//

import Vision
import VisionKit
import SwiftUI

public typealias CameraResult = Result<VNDocumentCameraScan, Error>
public typealias CancelAction = () -> Void
public typealias ResultAction = (CameraResult) -> Void

public struct DocumentCamera: UIViewControllerRepresentable {
    private let cancelAction: CancelAction
    private let resultAction: ResultAction
    
    public init(
        cancelAction: @escaping CancelAction = {},
        resultAction: @escaping ResultAction
    ) {
        self.cancelAction = cancelAction
        self.resultAction = resultAction
    }
    
    
    public func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let controller = VNDocumentCameraViewController()
        controller.delegate = context.coordinator
        return controller
    }
    
    public func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(
            cancelAction: cancelAction,
            resultAction: resultAction
        )
    }
}

//MARK: - Coordinator
extension DocumentCamera {
    public class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        private let cancelAction: CancelAction
        private let resultAction: ResultAction
        
        public init(
            cancelAction: @escaping CancelAction,
            resultAction: @escaping ResultAction
        ) {
            self.cancelAction = cancelAction
            self.resultAction = resultAction
        }
        
        public func documentCameraViewControllerDidCancel(
            _ controller: VNDocumentCameraViewController
        ) {
            cancelAction()
        }
        
        public func documentCameraViewController(
            _ controller: VNDocumentCameraViewController,
            didFailWithError error: Error
        ) {
            resultAction(.failure(error))
        }
        
        public func documentCameraViewController(
            _ controller: VNDocumentCameraViewController,
            didFinishWith scan: VNDocumentCameraScan
        ) {
            resultAction(.success(scan))
        }
    }
}
