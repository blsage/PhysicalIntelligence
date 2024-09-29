//
//  Model+ARSessionDelegate.swift
//  PhysicalIntelligence
//
//  Created by Benjamin Sage on 9/28/24.
//

import ARKit

extension Model: ARSessionDelegate {
    func startARSession() {
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

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard isRecording else { return }

        let imageBuffer = frame.capturedImage
        let imageData = imageBuffer.jpegData

        var depthData: Data?
        if let sceneDepth = frame.sceneDepth?.depthMap {
            depthData = sceneDepth.depthData
        }

        let recordedFrame = RecordedFrame(
            timestamp: frame.timestamp,
            cameraTransform: frame.camera.transform.toArray(),
            imageData: imageData,
            depthData: depthData
        )

        currentRecording?.frames.append(recordedFrame)
    }
}
