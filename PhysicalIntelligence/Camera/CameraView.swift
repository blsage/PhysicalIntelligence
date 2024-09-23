//
//  CameraView.swift
//  PhysicalIntelligence
//
//  Created by Benjamin Sage on 9/22/24.
//

import SwiftUI

struct CameraView: View {
    var body: some View {
        ARViewContainer()
            .overlay {
                CameraOverlayGrid()
                CameraCornerOverlay()
            }
            .overlay(alignment: .bottom) {
                RecordButton()
                    .padding()
            }
            .background {
                Color.black.ignoresSafeArea()
            }
    }
}

#Preview {
    CameraView()
}
