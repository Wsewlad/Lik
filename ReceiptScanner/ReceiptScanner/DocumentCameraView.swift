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

struct DocumentCamera: UIViewControllerRepresentable {
    private let cancelAction: CancelAction
    private let resultAction: ResultAction
    
    init(
        cancelAction: @escaping CancelAction = {},
        resultAction: @escaping ResultAction
    ) {
        self.cancelAction = cancelAction
        self.resultAction = resultAction
    }
    
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let controller = VNDocumentCameraViewController()
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(
            cancelAction: cancelAction,
            resultAction: resultAction
        )
    }
}

//MARK: - Coordinator
extension DocumentCamera {
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        
        private let cancelAction: CancelAction
        private let resultAction: ResultAction
        
        init(
            cancelAction: @escaping CancelAction,
            resultAction: @escaping ResultAction
        ) {
            self.cancelAction = cancelAction
            self.resultAction = resultAction
        }
        
        func documentCameraViewControllerDidCancel(
            _ controller: VNDocumentCameraViewController) {
                cancelAction()
            }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            resultAction(.failure(error))
        }
        
        func documentCameraViewController(
            _ controller: VNDocumentCameraViewController,
            didFinishWith scan: VNDocumentCameraScan
        ) {
            resultAction(.success(scan))
        }
    }
}

//protocol RecognizedTextDataSource: AnyObject {
//    func addRecognizedText(recognizedText: [VNRecognizedTextObservation])
//}

//extension DocumentCamera {
//    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
//        // Use this height value to differentiate between big labels and small labels in a receipt.
//        static let textHeightThreshold: CGFloat = 0.025
//
//        var textRecognitionRequest: VNRecognizeTextRequest
//
//        typealias ReceiptContentField = (name: String, value: String)
//
//        // The information to fetch from a scanned receipt.
//        struct ReceiptContents {
//
//            var name: String?
//            var items = [ReceiptContentField]()
//        }
//
//        var contents: ReceiptContents
        
//        override init() {
//            contents = ReceiptContents()
//
//            self.textRecognitionRequest = VNRecognizeTextRequest(completionHandler: { (request, error) in
//                if let results = request.results, !results.isEmpty {
//                    if let requestResults = request.results as? [VNRecognizedTextObservation] {
//                        DispatchQueue.main.async {
//                            self.addRecognizedText(recognizedText: requestResults)
//                        }
//                    }
//                }
//            })
//            // This doesn't require OCR on a live camera feed, select accurate for more accurate results.
//            textRecognitionRequest.recognitionLevel = .accurate
//            textRecognitionRequest.usesLanguageCorrection = true
//        }
//
//        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
//            for pageNumber in 0 ..< scan.pageCount {
//                let image = scan.imageOfPage(at: pageNumber)
//                self.processImage(image: image)
//            }
//        }
//    }
//}
//
//extension DocumentCamera.Coordinator: RecognizedTextDataSource {
//    func processImage(image: UIImage) {
//        guard let cgImage = image.cgImage else {
//            print("Failed to get cgimage from input image")
//            return
//        }
//
//        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
//        do {
//            try handler.perform([textRecognitionRequest])
//        } catch {
//            print(error)
//        }
//    }
//
//    func addRecognizedText(recognizedText: [VNRecognizedTextObservation]) {
//        // Create a full transcript to run analysis on.
//        var currLabel: String?
//        let maximumCandidates = 1
//        for observation in recognizedText {
//            guard let candidate = observation.topCandidates(maximumCandidates).first else { continue }
//            let isLarge = (observation.boundingBox.height > Self.textHeightThreshold)
//            var text = candidate.string
//            // The value might be preceded by a qualifier (e.g A small '3x' preceding 'Additional shot'.)
//            var valueQualifier: VNRecognizedTextObservation?
//
//            if isLarge {
//                if let label = currLabel {
//                    if let qualifier = valueQualifier {
//                        if abs(qualifier.boundingBox.minY - observation.boundingBox.minY) < 0.01 {
//                            // The qualifier's baseline is within 1% of the current observation's baseline, it must belong to the current value.
//                            let qualifierCandidate = qualifier.topCandidates(1)[0]
//                            text = qualifierCandidate.string + " " + text
//                        }
//                        valueQualifier = nil
//                    }
//                    contents.items.append((label, text))
//                    currLabel = nil
//                } else if contents.name == nil && observation.boundingBox.minX < 0.5 && text.count >= 2 {
//                    // Name is located on the top-left of the receipt.
//                    contents.name = text
//                }
//            } else {
//                if text.starts(with: "#") {
//                    // Order number is the only thing that starts with #.
//                    contents.items.append(("Order", text))
//                } else if currLabel == nil {
//                    currLabel = text
//                } else {
//                    do {
//                        // Create an NSDataDetector to detect whether there is a date in the string.
//                        let types: NSTextCheckingResult.CheckingType = [.date]
//                        let detector = try NSDataDetector(types: types.rawValue)
//                        let matches = detector.matches(in: text, options: .init(), range: NSRange(location: 0, length: text.count))
//                        if !matches.isEmpty {
//                            contents.items.append(("Date", text))
//                        } else {
//                            // This observation is potentially a qualifier.
//                            valueQualifier = observation
//                        }
//                    } catch {
//                        print(error)
//                    }
//
//                }
//            }
//        }
//    }
//}
