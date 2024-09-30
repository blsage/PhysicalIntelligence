//
//  SettingsSheet.swift
//  PhysicalIntelligence
//
//  Created by Benjamin Sage on 9/22/24.
//

import SwiftUI

struct SettingsSheet: View {
    @Environment(\.model) var model

    var body: some View {
        @Bindable var model = model
        NavigationStack {
            WelcomeSheet()
                .navigationTitle("")
                .navigationDestination(isPresented: $model.showLDAP) {
                    LDAPView()
                }
                .onAppear {
                    model.welcomeShown = true
                }
        }
        .interactiveDismissDisabled()
    }
}

#Preview {
    SettingsSheet()
        .environment(Model())
}
