//
//  WelcomeSheetSection.swift
//  PhysicalIntelligence
//
//  Created by Benjamin Sage on 9/22/24.
//

import SwiftUI

struct WelcomeSheetSection: View {
    var title: String
    var subtitle: String
    var icon: String

    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: "person.3.sequence.fill")
                .opacity(0)
                .overlay {
                    Image(systemName: icon)
                        .foregroundColor(.white)
                    Image(systemName: icon)
                }
                .foregroundStyle(.blurple.gradient)
                .font(.largeTitle)
            VStack(alignment: .leading) {
                Text(title)
                Text(subtitle)
                    .fontWeight(.light)
            }
            .font(.body)
        }
    }
}

#Preview {
    WelcomeSheetSection(
        title: "Hello world",
        subtitle: "This is a section",
        icon: "person.3.sequence.fill"
    )
}
