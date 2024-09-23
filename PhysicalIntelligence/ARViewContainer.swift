//
//  ARViewContainer.swift
//  PhysicalIntelligence
//
//  Created by Benjamin Sage on 9/22/24.
//

import SwiftUI
import RealityKit

struct ARViewContainer: UIViewRepresentable {

    func makeUIView(context: Context) -> UIView {
        let arView = ARView(frame: .zero)

        // Add a simple RealityKit object for testing purposes
        let mesh = MeshResource.generateBox(size: 0.1, cornerRadius: 0.005)
        let material = SimpleMaterial(color: .gray, roughness: 0.15, isMetallic: true)
        let model = ModelEntity(mesh: mesh, materials: [material])
        model.transform.translation.y = 0.05

        // Create a horizontal plane anchor for the content
        let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))
        anchor.addChild(model)

        // Add the anchor to the ARView's scene
        arView.scene.anchors.append(anchor)

        return arView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // No need to update for now
    }
}
