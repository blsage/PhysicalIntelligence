//
//  AppIconView.swift
//  PhysicalIntelligence
//
//  Created by Benjamin Sage on 9/22/24.
//

import SwiftUI

struct AppIconView: View {
    var body: some View {
        Text("π")
            .font(.system(size: 1500, weight: .black, design: .serif))
            .offset(y: -100)
    }
}

#Preview(traits: .fixedLayout(width: 2000, height: 2000)) {
    AppIconView()
}
