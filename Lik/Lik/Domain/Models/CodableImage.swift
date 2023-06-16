//
//  CodableImage.swift
//  Lik
//
//  Created by  Vladyslav Fil on 15.06.2023.
//

import Foundation
import UIKit

struct CodableImage: Codable, Equatable {
    let image: UIImage
    
    enum CodingKeys: String, CodingKey {
        case imageData
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let imageData = try container.decode(Data.self, forKey: .imageData)
        guard let image = UIImage(data: imageData) else {
            throw DecodingError.dataCorruptedError(forKey: .imageData,
                                                   in: container,
                                                   debugDescription: "Failed to decode image data.")
        }
        self.image = image
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            throw EncodingError.invalidValue(image, EncodingError.Context(codingPath: [CodingKeys.imageData],
                                                                          debugDescription: "Failed to encode image data."))
        }
        try container.encode(imageData, forKey: .imageData)
    }
}
