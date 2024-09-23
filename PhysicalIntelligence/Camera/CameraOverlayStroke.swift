//
//  CameraOverlayStroke.swift
//  PhysicalIntelligence
//
//  Created by Benjamin Sage on 9/23/24.
//

import SwiftUI

extension Shape {
    func cameraOverlayStroke() -> some View {
        self
            .stroke(Color.white.opacity(0.5), lineWidth: 1)
    }
}
