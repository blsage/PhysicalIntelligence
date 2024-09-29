//
//  App.swift
//  PhysicalIntelligence
//
//  Created by Benjamin Sage on 9/22/24.
//

import SwiftUI
import Amplify
import AWSCognitoAuthPlugin
import AWSS3StoragePlugin

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

    init() {
        configureAmplify()
    }

    func configureAmplify() {
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.add(plugin: AWSS3StoragePlugin())
            try Amplify.configure()
            print("Amplify configured with auth and storage plugins")

            Task {
                do {
                    try await Amplify.Auth.signIn()
                }
            }
        } catch {
            print("Failed to initialize Amplify: \(error)")
        }
    }
}
