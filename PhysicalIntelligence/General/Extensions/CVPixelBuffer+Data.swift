//
//  CVPixelBuffer+Data.swift
//  PhysicalIntelligence
//
//  Created by Benjamin Sage on 9/28/24.
//

import ARKit

extension CVPixelBuffer {
    var jpegData: Data {
        let ciImage = CIImage(cvPixelBuffer: self)
        let context = CIContext()
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            let uiImage = UIImage(cgImage: cgImage)
            if let jpegData = uiImage.jpegData(compressionQuality: 0.8) {
                return jpegData
            }
        }
        return Data()
    }

    var depthData: Data {
        CVPixelBufferLockBaseAddress(self, .readOnly)
        let dataSize = CVPixelBufferGetDataSize(self)
        let baseAddress = CVPixelBufferGetBaseAddress(self)
        let data = Data(bytes: baseAddress!, count: dataSize)
        CVPixelBufferUnlockBaseAddress(self, .readOnly)
        return data
    }
}
