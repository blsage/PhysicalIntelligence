//
//  StatusBarLabel.swift
//  PhysicalIntelligence
//
//  Created by Benjamin Sage on 9/23/24.
//

import SwiftUI

struct StatusBarLabel: View {
    var text: String

    var body: some View {
        Text(text)
            .font(.callout)
            .monospaced()
            .minimumScaleFactor(0.3)
            .lineLimit(1)
            .shadow(radius: 1)
    }
}

#Preview {
    StatusBarLabel(text: "hello_world")
}
