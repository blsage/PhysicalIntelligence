//
//  StatusBar.swift
//  PhysicalIntelligence
//
//  Created by Benjamin Sage on 9/22/24.
//

import SwiftUI
import SageKit

struct StatusBar: View {
    @State private var timeWidth: CGFloat = 0
    @State private var stackWidth: CGFloat = 0

    var padding: CGFloat = 12

    var maxSideWidth: CGFloat {
        let width = stackWidth / 2 - timeWidth / 2 - padding
        guard width.isFinite, width > 0 else { return 0 }
        return width
    }

    var body: some View {
        ZStack {
            ZStack {
                StatusBarLabel(text: "surajnair")
                    .frame(maxWidth: maxSideWidth, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            TimeLabel()
                .measure(.width, $timeWidth)

            ZStack {
                StatusBarLabel(text: "initial_run_112")
                    .frame(maxWidth: maxSideWidth, alignment: .trailing)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .measure(.width, $stackWidth)
        .padding()
        .frame(maxWidth: .infinity)
        .colorScheme(.dark)
        .background {
            Color.black.ignoresSafeArea()
        }
    }
}

#Preview {
    StatusBar()
}
