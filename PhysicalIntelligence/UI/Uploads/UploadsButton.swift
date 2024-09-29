//
//  UploadsButton.swift
//  PhysicalIntelligence
//
//  Created by Benjamin Sage on 9/29/24.
//

import SwiftUI

struct UploadsButton: View {
    @Environment(\.model) var model

    var body: some View {
        Button {
            model.showUploadsSheet = true
        } label: {
            Color.secondary
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 5))
        }
    }
}

#Preview {
    UploadsButton()
        .environment(Model())
}
