//
//  RecordingData+Sample.swift
//  PhysicalIntelligence
//
//  Created by Benjamin Sage on 10/9/24.
//

import UIKit

extension RecordingData {
    static var sampleRecording: RecordingData {
        let sampleFrame = RecordedFrame(
            timestamp: Date().timeIntervalSince1970,
            cameraTransform: [
                1.0, 0.0, 0.0, 0.0,
                0.0, 1.0, 0.0, 0.0,
                0.0, 0.0, 1.0, 0.0,
                0.0, 0.0, 0.0, 1.0
            ],
            imageData: sampleImageData,
            depthData: nil,
            depthConfidence: nil
        )

        let recording = RecordingData(frames: [sampleFrame])
        recording.startTime = Date()
        return recording
    }

    static var sampleImageData: Data {
        let image = UIImage(systemName: "video") ?? UIImage()
        return image.jpegData(compressionQuality: 1.0) ?? Data()
    }
}
