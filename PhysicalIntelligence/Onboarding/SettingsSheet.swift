//
//  SettingsSheet.swift
//  PhysicalIntelligence
//
//  Created by Benjamin Sage on 9/22/24.
//

import SwiftUI

struct SettingsSheet: View {
    @EnvironmentObject var model: Model

    var body: some View {
        NavigationStack(path: $model.onboardingPath) {
            WelcomeSheet()
                .navigationTitle("")
                .navigationDestination(for: OnboardingPage.self) { page in
                    switch page {
                    case .ldap:
                        LDAPView()
                    case .taskID:
                        NameTaskView()
                    }
                }
        }
        .interactiveDismissDisabled()
    }
}

#Preview {
    SettingsSheet()
        .environmentObject(Model())
}
