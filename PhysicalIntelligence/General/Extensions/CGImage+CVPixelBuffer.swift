//
//  CGImage+CVPixelBuffer.swift
//  PhysicalIntelligence
//
//  Created by Benjamin Sage on 9/29/24.
//

import CoreGraphics
import AVKit

extension CGImage {
    var pixelBuffer: CVPixelBuffer? {
        let frameSize = CGSize(width: self.width, height: self.height)
        var pixelBuffer: CVPixelBuffer?

        let options: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
        ]

        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            Int(frameSize.width),
            Int(frameSize.height),
            kCVPixelFormatType_32ARGB,
            options as CFDictionary,
            &pixelBuffer
        )

        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }

        CVPixelBufferLockBaseAddress(buffer, [])
        let pxData = CVPixelBufferGetBaseAddress(buffer)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()

        guard let context = CGContext(
            data: pxData,
            width: Int(frameSize.width),
            height: Int(frameSize.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: rgbColorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        ) else {
            CVPixelBufferUnlockBaseAddress(buffer, [])
            return nil
        }

        context.draw(self, in: CGRect(origin: .zero, size: frameSize))
        CVPixelBufferUnlockBaseAddress(buffer, [])
        return buffer
    }
}
