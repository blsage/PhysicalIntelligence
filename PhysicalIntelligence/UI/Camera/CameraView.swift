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
            .overlay(alignment: .bottom) {
                RecordButton()
                    .padding()
            }
            .overlay(alignment: .bottomLeading) {
                UploadsButton()
                    .padding()
            }
            .background {
                Color.black.ignoresSafeArea()
            }
    }
}

#Preview {
    CameraView()
        .environment(Model())
}
