//
//  RecordingView.swift
//  PhysicalIntelligence
//
//  Created by Benjamin Sage on 9/23/24.
//

import SwiftUI

struct RecordingView: View {
    var body: some View {
        CameraView()
            .overlay(alignment: .top) {
                StatusBar()
            }
    }
}

#Preview {
    VStack(spacing: 0) {
        RecordingView()
    }
    .colorScheme(.dark)
    .background {
        Color.black.ignoresSafeArea()
    }
    .environment(Model())
}
