//
//  Model+ARSessionDelegate.swift
//  PhysicalIntelligence
//
//  Created by Benjamin Sage on 9/28/24.
//

import ARKit
import RealityKit

extension Model: ARSessionDelegate {
    func startARSession(for arView: ARView) {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.environmentTexturing = .automatic

        if ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth) {
            configuration.frameSemantics.insert(.sceneDepth)
        }

        arView.session.delegate = self
        arView.session.run(configuration)

        currentRecording?.startTime = Date()
    }

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        print("here")
        guard isRecording else { return }

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

        currentRecording?.frames.append(recordedFrame)
    }
}
