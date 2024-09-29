//
//  RecordingData.swift
//  PhysicalIntelligence
//
//  Created by Benjamin Sage on 9/29/24.
//

import SwiftData
import Foundation
import UIKit

class RecordingData: Identifiable, Codable {
    var id: UUID = UUID()
    var startTime: Date?
    var frames: [RecordedFrame]

    init(frames: [RecordedFrame]) {
        self.frames = frames
        self.startTime = Date()
    }
}

// MARK: - Sample

extension RecordingData {
    static var sampleRecording: RecordingData {
        // Create a sample frame with mock data
        let sampleFrame = RecordedFrame(
            timestamp: Date().timeIntervalSince1970,
            cameraTransform: [1.0, 0.0, 0.0, 0.0,
                              0.0, 1.0, 0.0, 0.0,
                              0.0, 0.0, 1.0, 0.0,
                              0.0, 0.0, 0.0, 1.0],
            imageData: sampleImageData,
            depthData: nil,
            depthConfidence: nil
        )

        // Create a sample recording with the sample frame
        let recording = RecordingData(frames: [sampleFrame])
        recording.startTime = Date()
        return recording
    }

    static var sampleImageData: Data {
        // Use a system image for sample image data
        let image = UIImage(systemName: "video") ?? UIImage()
        return image.jpegData(compressionQuality: 1.0) ?? Data()
    }
}
