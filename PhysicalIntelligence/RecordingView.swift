//
//  RecordingView.swift
//  PhysicalIntelligence
//
//  Created by Benjamin Sage on 9/23/24.
//

import SwiftUI

struct RecordingView: View {
    var body: some View {
        StatusBar()
        CameraView()
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
}
