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
        let arView = ARView(frame: .zero)

        model.startARSession(for: arView)

        return arView
    }

    func updateUIView(_ arView: ARView, context: Context) {

    }
}
