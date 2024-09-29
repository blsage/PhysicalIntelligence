//
//  Model.swift
//  PhysicalIntelligence
//
//  Created by Benjamin Sage on 9/22/24.
//

import Foundation
import ARKit
import SwiftData
import SwiftUI
import Combine
import UIKit

@Observable class Model: NSObject {
    var welcomeShown: Bool = false // persist
    var showSettingsSheet = false
    var showLDAPSheet = false
    var showLDAP = false
    var ldap = "" // persist
    var taskID = ""
    var showLogoutConfirmation = false
    var recordingTime: TimeInterval = 0
    var isRecording = false
    var lastFrame: TimeInterval = 0

    var timerCancellable: AnyCancellable?

    var session = ARSession()
    var currentRecording: RecordingData?
    var modelContext: ModelContext?

    override init() {
        super.init()
    }

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    func saveRecording() {
        guard let recording = currentRecording, let modelContext = modelContext else { return }
        do {
            modelContext.insert(recording)
            try modelContext.save()
            print("Recording saved successfully.")
        } catch {
            print("Error saving recording: \(error)")
        }
    }

}

@Model
class RecordedFrame: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
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
    }
}

@Model
class RecordingData: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    var startTime: Date?
    var frames: [RecordedFrame]

    init(frames: [RecordedFrame]) {
        self.frames = frames
    }
}

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
