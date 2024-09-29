//
//  WelcomeSheet.swift
//  PhysicalIntelligence
//
//  Created by Benjamin Sage on 9/22/24.
//

import SwiftUI

struct WelcomeSheet: View {
    @Environment(\.model) var model

    var body: some View {
        VStack(alignment: .leading) {
            Text("Welcome to")
            Text("Physical Intelligence")
                .foregroundStyle(.tint)

            VStack(alignment: .leading, spacing: 30) {
                WelcomeSheetSection(
                    title: "Capture High-Quality Data",
                    subtitle: "Easily record images and track positions from your iPhone in real time.",
                    icon: "iphone.rear.camera"
                )
                WelcomeSheetSection(
                    title: "Streamlined Metadata Entry",
                    subtitle: "Provide important details quickly and efficiently.",
                    icon: "number.square.fill"
                )
                WelcomeSheetSection(
                    title: "Secure Data Upload",
                    subtitle: "Your data is safe, fast, and always accessible.",
                    icon: "square.and.arrow.up.on.square.fill"
                )
            }
            .padding(.vertical, 30)

            Button("Get started") {
                model.showLDAP = true
            }
            .buttonStyle(StretchedButtonStyle())
            .foregroundStyle(.white, .blurple)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 30)

            Text("(c) 2024 Physical Intelligence")
                .font(.caption2)
                .fontWeight(.light)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)

        }
        .font(.largeTitle)
        .bold()
        .padding(35)
    }
}

#Preview {
    WelcomeSheet()
        .tint(.blurple)
        .environment(Model())
}
