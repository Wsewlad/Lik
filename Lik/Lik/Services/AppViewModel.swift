//
//  AppViewModel.swift
//  ReceiptScanner
//
//  Created by  Vladyslav Fil on 14.01.2023.
//

import AVKit
import Foundation
import SwiftUI
import VisionKit

//@EnvironmentObject var viewModel: AppViewModel

//switch viewModel.dataScannerAccessStatus {
//case .scannerAvailable:
//    break
//case .cameraNotAvailable:
//    Text("Camera isn't available")
//case .scannerNotAvailable:
//    Text("This device doesn't support text scanning")
//case .notDetermined:
//    Text("Requestion camera access")
//case .cameraAccessNotGranted:
//    Text("Please provide access to the camera in settings")
//}

enum ScanType: String {
    case barcode, text
}

enum DataScannerAccesstatusType {
    case notDetermined
    case cameraAccessNotGranted
    case cameraNotAvailable
    case scannerAvailable
    case scannerNotAvailable
}

@MainActor
final class AppViewModel: ObservableObject {
    @Published var dataScannerAccessStatus: DataScannerAccesstatusType = .notDetermined
    @Published var recognizedItems: [RecognizedItem] = []
    @Published var scanType: ScanType = .barcode
    @Published var textContentType: DataScannerViewController.TextContentType?
    @Published var recognizesMultipleItems: Bool = false
    
    var recognizedDataType: DataScannerViewController.RecognizedDataType {
        scanType == .barcode ? .barcode() : .text(textContentType: textContentType)
    }
    
    var textContentTypes: [(String, DataScannerViewController.TextContentType?)] = [
        ("All", .none),
        ("URL", .URL),
        ("Phone", .telephoneNumber),
        ("Email", .emailAddress),
        ("Address", .fullStreetAddress)
    ]
    
    var headerText: String {
        if recognizedItems.isEmpty {
            return "Scanning \(scanType.rawValue)"
        }
        return "Recognized \(recognizedItems.count) items"
    }
    
    var dataScannerViewId: Int {
        var hasher = Hasher()
        hasher.combine(scanType)
        hasher.combine(recognizesMultipleItems)
        if let textContentType {
            hasher.combine(textContentType)
        }
        return hasher.finalize()
    }
}

//MARK: - DataScannerAccessStatus
extension AppViewModel {
    private var isScannerAvailable: Bool {
        DataScannerViewController.isAvailable && DataScannerViewController.isSupported
    }
    
    func requestDataScannerAccessStatus() async {
        guard UIImagePickerController.isCameraDeviceAvailable(.rear) else {
            dataScannerAccessStatus = .cameraNotAvailable
            return
        }
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            if granted {
                dataScannerAccessStatus = isScannerAvailable ? .scannerAvailable : .scannerNotAvailable
            } else {
                dataScannerAccessStatus = .cameraAccessNotGranted
            }
        case .restricted, .denied:
            dataScannerAccessStatus = .cameraAccessNotGranted
        case .authorized:
            dataScannerAccessStatus = isScannerAvailable ? .scannerAvailable : .scannerNotAvailable
        @unknown default:
            break
        }
    }
}
