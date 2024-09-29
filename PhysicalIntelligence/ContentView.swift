//
//  ContentView.swift
//  PhysicalIntelligence
//
//  Created by Benjamin Sage on 9/22/24.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    @Environment(\.model) var model

    var body: some View {
        @Bindable var model = model

        VStack(spacing: 0) {
            RecordingView()
        }
        .taskIDAlert()
        .sheet(isPresented: $model.showSettingsSheet) {
            SettingsSheet()
        }
        .sheet(isPresented: $model.showLDAPSheet) {
            LDAPView()
        }
        .sheet(isPresented: $model.showUploadsSheet) {
            UploadsView()
        }
        .onAppear {
            model.showAppropriateSheet()
        }
    }
}

#Preview {
    ContentView()
        .tint(.blurple)
        .environment(Model())
}
