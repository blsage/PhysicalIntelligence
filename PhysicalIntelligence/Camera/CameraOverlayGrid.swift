//
//  CameraOverlayGrid.swift
//  PhysicalIntelligence
//
//  Created by Benjamin Sage on 9/22/24.
//

import SwiftUI

struct CameraOverlayGrid: View {
    var body: some View {
        CameraGrid()
            .cameraOverlayStroke()
    }
}

struct CameraGrid: Shape {
    // swiftlint:disable identifier_name
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let cellWidth = rect.width / 3
        let cellHeight = rect.height / 3

        for i in 1..<3 {
            let xPos = CGFloat(i) * cellWidth
            path.move(to: CGPoint(x: xPos, y: 0))
            path.addLine(to: CGPoint(x: xPos, y: rect.height))
        }

        for i in 1..<3 {
            let yPos = CGFloat(i) * cellHeight
            path.move(to: CGPoint(x: 0, y: yPos))
            path.addLine(to: CGPoint(x: rect.width, y: yPos))
        }

        return path
    }
    // swiftlint:enable identifier_name
}

#Preview {
    Color.black
        .overlay {
            CameraOverlayGrid()
        }
}
