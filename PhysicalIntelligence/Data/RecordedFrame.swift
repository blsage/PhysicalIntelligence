//
//  RecordedFrame.swift
//  PhysicalIntelligence
//
//  Created by Benjamin Sage on 9/29/24.
//

import Foundation

class RecordedFrame: Identifiable, Codable {
    var id: UUID = UUID()
    var timestamp: TimeInterval
    var cameraTransform: [Float]
    var imageData: Data
    var depthData: Data?
    var depthConfidence: Data?

    init(timestamp: TimeInterval, cameraTransform: [Float], imageData: Data, depthData: Data?, depthConfidence: Data?) {
        self.timestamp = timestamp
        self.cameraTransform = cameraTransform
        self.imageData = imageData
        self.depthData = depthData
        self.depthConfidence = depthConfidence
    }
}
