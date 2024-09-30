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
            .ignoresSafeArea()
            .overlay(alignment: .bottom) {
                RecordButton()
                    .frame(maxWidth: .infinity)
                    .overlay(alignment: .leading) {
                        UploadsButton()
                    }
                    .padding()
            }
            .background {
                Color.black.ignoresSafeArea()
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

#Preview {
    CameraView()
        .environment(Model())
}
