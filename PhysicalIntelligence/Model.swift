//
//  Model.swift
//  PhysicalIntelligence
//
//  Created by Benjamin Sage on 9/22/24.
//

import Foundation
import ARKit
import SwiftData
import Combine
import UIKit

@Observable public class Model: NSObject, ARSessionDelegate {
    var welcomeShown = false // persist
    var showSettingsSheet = false
    var showLDAPSheet = false
    var showLDAP = false
    var ldap = "" // persist
    var taskID = ""
    var showLogoutConfirmation = false
    var recordingTime: TimeInterval = 0
    var isRecording = false

    private var timerCancellable: AnyCancellable?

    private let session = ARSession()
    private var configuration: ARWorldTrackingConfiguration?
    private var currentRecording: RecordingData?
    private var modelContext: ModelContext?

    override init() {
        super.init()
    }

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    func ldapDone() {
        showSettingsSheet = false
        showLDAPSheet = false
    }

    func toggleRecording() {
        if isRecording {
            isRecording = false
            recordingTime = 0
            session.pause()
            saveRecording()
            currentRecording = nil
            timerCancellable?.cancel()
            timerCancellable = nil
        } else {
            startARSession()
            currentRecording = RecordingData(frames: [])
            currentRecording?.startTime = Date()
            isRecording = true
            recordingTime = 0
            timerCancellable = Timer.publish(every: 0.1, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] _ in
                    Task { @MainActor in
                        if let startTime = self?.currentRecording?.startTime {
                            self?.recordingTime = Date().timeIntervalSince(startTime)
                        }
                    }
                }
        }
    }

    private func startARSession() {
        guard ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth) else {
            print("Device does not support scene depth.")
            return
        }

        configuration = ARWorldTrackingConfiguration()
        configuration?.planeDetection = [.horizontal, .vertical]
        configuration?.environmentTexturing = .automatic
        configuration?.frameSemantics = [.sceneDepth]

        session.delegate = self
        session.run(configuration!)

        currentRecording?.startTime = Date()
    }

    public func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard isRecording else { return }

        let imageBuffer = frame.capturedImage
        let imageData = imageBufferToJPEGData(imageBuffer)

        var depthData: Data?
        if let sceneDepth = frame.sceneDepth?.depthMap {
            depthData = depthBufferToData(sceneDepth)
        }

        let recordedFrame = RecordedFrame(
            timestamp: frame.timestamp,
            cameraTransform: frame.camera.transform.toArray(),
            imageData: imageData,
            depthData: depthData
        )

        currentRecording?.frames.append(recordedFrame)
    }

    private func saveRecording() {
        guard let recording = currentRecording, let modelContext = modelContext else { return }
        do {
            modelContext.insert(recording)
            try modelContext.save()
            print("Recording saved successfully.")
        } catch {
            print("Error saving recording: \(error)")
        }
    }

    private func imageBufferToJPEGData(_ pixelBuffer: CVPixelBuffer) -> Data {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            let uiImage = UIImage(cgImage: cgImage)
            if let jpegData = uiImage.jpegData(compressionQuality: 0.8) {
                return jpegData
            }
        }
        return Data()
    }

    private func depthBufferToData(_ pixelBuffer: CVPixelBuffer) -> Data {
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        let dataSize = CVPixelBufferGetDataSize(pixelBuffer)
        let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
        let data = Data(bytes: baseAddress!, count: dataSize)
        CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
        return data
    }
}

extension simd_float4x4 {
    func toArray() -> [Float] {
        let columns = [self.columns.0, self.columns.1, self.columns.2, self.columns.3]
        return columns.flatMap { [$0.x, $0.y, $0.z, $0.w] }
    }
}

@Model
class RecordedFrame: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    var timestamp: TimeInterval
    var cameraTransform: [Float]
    var imageData: Data
    var depthData: Data?

    init(timestamp: TimeInterval, cameraTransform: [Float], imageData: Data, depthData: Data?) {
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
            depthData: nil
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
