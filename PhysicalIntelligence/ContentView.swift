//
//  ContentView.swift
//  PhysicalIntelligence2
//
//  Created by Benjamin Sage on 9/22/24.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    @EnvironmentObject var model: Model

    var body: some View {
        VStack(spacing: 0) {
            RecordingView()
        }
        .sheet(isPresented: $model.showSettingsSheet) {
            SettingsSheet()
        }
        .onAppear {
            model.showSettingsSheet = true
        }
    }
}

#Preview {
    ContentView()
        .tint(.blurple)
        .environmentObject(Model())
}
