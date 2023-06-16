//
//  ImageCrop.swift
//  Lik
//
//  Created by  Vladyslav Fil on 16.06.2023.
//

import UIKit
import Vision
import Combine

struct Contour: Identifiable {
    var id: UUID = .init()
    var vnContour: VNContour
}

class ContourDetector {
    static let shared = ContourDetector()
  
    private init() {}
    
    //MARK: - Contours Request
    lazy var contoursRequest: VNDetectContoursRequest = {
        let req = VNDetectContoursRequest()
        req.detectsDarkOnLight = false
//        req.contrastAdjustment = 0.5
//        req.contrastPivot = 1
        return req
    }()
    
    //MARK: - Perform request
    func perform(request: VNRequest, on image: CGImage) throws -> VNRequest {
        let requestHandler = VNImageRequestHandler(cgImage: image, options: [:])
        try requestHandler.perform([request])
        return request
    }
    
    //MARK: - Post Process Contours
    func postProcessContours(image: CGImage?, request: VNRequest) -> [Contour] {
        guard let results = request.results as? [VNContoursObservation] else {
            return []
        }
        let vnContours = results.flatMap { contour in
            (0..<contour.contourCount).compactMap { try? contour.contour(at: $0) }
        }
        let contours = vnContours.map { Contour(vnContour: $0) }
//        let conturedImage = self.drawContours(contoursObservation: results.first!, sourceImage: image!)
        return contours
    }

    //MARK: - Process Contours
    func processContours(image: CGImage?) throws -> [Contour] {
        guard let image = image else {
            return []
        }
        
        let contourRequest = try perform(request: contoursRequest, on: image)
        return postProcessContours(image: image, request: contourRequest)
    }
    
    func processSaliency(image: CGImage?) {
        
    }

    func drawContours(contoursObservation: VNContoursObservation, sourceImage: CGImage) -> UIImage {
        let size = CGSize(width: sourceImage.width, height: sourceImage.height)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let renderedImage = renderer.image { (context) in
            let renderingContext = context.cgContext

//            let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: size.height)
//            renderingContext.concatenate(flipVertical)

            renderingContext.draw(sourceImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            
            renderingContext.scaleBy(x: size.width, y: size.height)
            renderingContext.setLineWidth(5.0 / CGFloat(size.width))
            let redUIColor = UIColor.red
            renderingContext.setStrokeColor(redUIColor.cgColor)
            renderingContext.addPath(contoursObservation.normalizedPath)
            renderingContext.strokePath()
        }
        
        return renderedImage
    }
}



func detectAndCropWhiteArea(in image: UIImage) -> Future<UIImage?, Never> {
    return Future<UIImage?, Never> { promise in
        let detector = ContourDetector.shared
        
        let saliencyRequest = VNGenerateObjectnessBasedSaliencyImageRequest()
        let performedSaliencyRequest = try? detector.perform(request: saliencyRequest, on: image.cgImage!)
        let saliencyObservation = performedSaliencyRequest?.results?.first as? VNSaliencyImageObservation
        var unionOfSalientRegions = CGRect(x: 0, y: 0, width: 0, height: 0)
        let salientObjects = saliencyObservation?.salientObjects ?? []
        for salientObject in salientObjects {
            unionOfSalientRegions = unionOfSalientRegions.union(salientObject.boundingBox)
        }
        let ciimage = CIImage(image: image)!
        let salientRect = VNImageRectForNormalizedRect(unionOfSalientRegions,
                                                       Int(ciimage.extent.size.width),
                                                    Int(ciimage.extent.size.height))
        guard let croppedCGImage = image.cgImage?.cropping(to: salientRect) else {
            promise(.success(nil))
            return
        }
                
        
        let croppedImage = UIImage(cgImage: croppedCGImage)
        promise(.success(croppedImage))
    }
}
