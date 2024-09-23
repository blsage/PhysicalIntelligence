//
//  CameraCornerOverlay.swift
//  PhysicalIntelligence
//
//  Created by Benjamin Sage on 9/22/24.
//

import SwiftUI

struct CameraCornerOverlay: View {
    var body: some View {
        CameraCorners()
            .cameraOverlayStroke()
    }
}

struct CameraCorners: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let cornerLength: CGFloat = 30
        let lineThickness: CGFloat = 1

        // Top left corner
        path.move(to: CGPoint(x: 0, y: lineThickness))
        path.addLine(to: CGPoint(x: cornerLength, y: lineThickness))
        path.move(to: CGPoint(x: lineThickness, y: 0))
        path.addLine(to: CGPoint(x: lineThickness, y: cornerLength))

        // Top right corner
        path.move(to: CGPoint(x: rect.width - cornerLength, y: lineThickness))
        path.addLine(to: CGPoint(x: rect.width, y: lineThickness))
        path.move(to: CGPoint(x: rect.width - lineThickness, y: 0))
        path.addLine(to: CGPoint(x: rect.width - lineThickness, y: cornerLength))

        // Bottom left corner
        path.move(to: CGPoint(x: 0, y: rect.height - lineThickness))
        path.addLine(to: CGPoint(x: cornerLength, y: rect.height - lineThickness))
        path.move(to: CGPoint(x: lineThickness, y: rect.height))
        path.addLine(to: CGPoint(x: lineThickness, y: rect.height - cornerLength))

        // Bottom right corner
        path.move(to: CGPoint(x: rect.width - cornerLength, y: rect.height - lineThickness))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height - lineThickness))
        path.move(to: CGPoint(x: rect.width - lineThickness, y: rect.height))
        path.addLine(to: CGPoint(x: rect.width - lineThickness, y: rect.height - cornerLength))

        return path
    }
}

#Preview {
    CameraCornerOverlay()
}
