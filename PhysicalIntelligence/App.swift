//
//  App.swift
//  PhysicalIntelligence
//
//  Created by Benjamin Sage on 9/22/24.
//

import SwiftUI

@main
struct PhysicalIntelligenceApp: App {
    @State var model = Model()
    @Environment(\.modelContext) var modelContext

    var body: some Scene {
        WindowGroup {
            ContentView()
                .tint(.pink)
                .onAppear {
                    model.setModelContext(modelContext)
                }
                .environment(model)
        }
    }

}
