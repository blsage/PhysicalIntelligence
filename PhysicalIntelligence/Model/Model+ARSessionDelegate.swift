//
//  Model+ARSessionDelegate.swift
//  PhysicalIntelligence
//
//  Created by Benjamin Sage on 9/28/24.
//

import ARKit

extension Model: ARSessionDelegate {
    func startARSession() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.environmentTexturing = .automatic

        if ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth) {
            configuration.frameSemantics.insert(.sceneDepth)
        }

        session.delegate = self
        session.run(configuration)

        currentRecording?.startTime = Date()
    }

    nonisolated func session(_ session: ARSession, didUpdate frame: ARFrame) {
        Task {
            guard await isRecording else { return }

            let imageBuffer = frame.capturedImage
            let imageData = imageBuffer.jpegData

            var depthData: Data?
            var depthConfidence: Data?

            if let sceneDepth = frame.sceneDepth {
                depthData = sceneDepth.depthMap.depthData
                depthConfidence = sceneDepth.confidenceMap?.depthData
            }

            let recordedFrame = RecordedFrame(
                timestamp: frame.timestamp,
                cameraTransform: frame.camera.transform.array,
                imageData: imageData,
                depthData: depthData,
                depthConfidence: depthConfidence
            )

            Task { @MainActor in
                currentRecording?.frames.append(recordedFrame)
            }
        }
    }
}
