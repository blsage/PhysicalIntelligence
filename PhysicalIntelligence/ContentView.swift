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
    @State private var taskID = ""

    var body: some View {
        @Bindable var model = model

        VStack(spacing: 0) {
            RecordingView()
        }
        .alert("Task ID", isPresented: $model.showTaskIDAlert) {
            TextField("put_away_dishes", text: $taskID)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            Button("Record") {
                model.taskID = taskID.lowercased()
                model.tryStartRecording()
            }
        } message: {
            Text("Name this task.")
        }
        .sheet(isPresented: $model.showSettingsSheet) {
            SettingsSheet()
        }
        .sheet(isPresented: $model.showLDAPSheet) {
            LDAPView()
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
