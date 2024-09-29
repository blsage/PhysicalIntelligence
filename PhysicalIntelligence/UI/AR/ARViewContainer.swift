//
//  ARViewContainer.swift
//  PhysicalIntelligence
//
//  Created by Benjamin Sage on 9/22/24.
//

import ARKit
import SwiftUI
import RealityKit

struct ARViewContainer: UIViewRepresentable {
    @Environment(Model.self) var model

    func makeUIView(context: Context) -> ARView {
        @Bindable var model = model

        let arView = ARView(frame: .zero)

        model.session = arView.session
        model.startARSession()

//        let mesh = MeshResource.generateBox(size: 0.1, cornerRadius: 0.005)
//        let material = SimpleMaterial(color: .gray, roughness: 0.15, isMetallic: true)
//        let model = ModelEntity(mesh: mesh, materials: [material])
//        model.transform.translation.y = 0.05
//
//        let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))
//        anchor.addChild(model)
//
//        arView.scene.anchors.append(anchor)

        return arView
    }

    func updateUIView(_ arView: ARView, context: Context) { }
}
