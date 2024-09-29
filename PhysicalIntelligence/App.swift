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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .tint(.blurple)
                .environment(model)
        }
    }
}
