//
//  Model+ARSessionDelegate.swift
//  PhysicalIntelligence
//
//  Created by Benjamin Sage on 9/28/24.
//

import ARKit

extension Model: ARSessionDelegate {
    func startARSession() {
        configuration = ARWorldTrackingConfiguration()
        configuration?.planeDetection = [.horizontal, .vertical]
        configuration?.environmentTexturing = .automatic
        configuration?.frameSemantics = [.sceneDepth]

        session.delegate = self
        session.run(configuration!)

        currentRecording?.startTime = Date()
    }

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard isRecording, lastFrame == 0 || lastFrame + 1/31 < frame.timestamp else { return }

        lastFrame = frame.timestamp

        let imageBuffer = frame.capturedImage
        let imageData = imageBuffer.jpegData

        var depthData: Data?
        var depthConfidence: Data?
        if let sceneDepth = frame.sceneDepth?.depthMap {
            depthData = sceneDepth.depthData
        }
        if let sceneDepthConfidence = frame.sceneDepth?.confidenceMap {
            depthConfidence = sceneDepthConfidence.depthData
        }

        let recordedFrame = RecordedFrame(
            timestamp: frame.timestamp,
            cameraTransform: frame.camera.transform.array,
            imageData: imageData,
            depthData: depthData,
            depthConfidence: depthConfidence
        )

        currentRecording?.frames.append(recordedFrame)
    }
}
