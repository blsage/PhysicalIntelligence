//
//  StatusBar.swift
//  PhysicalIntelligence
//
//  Created by Benjamin Sage on 9/22/24.
//

import SwiftUI
import SageKit

struct StatusBar: View {
    @Environment(\.model) var model

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
                ldap
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            TimeLabel()
                .measure(.width, $timeWidth)

            ZStack {
                taskID
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

    var taskID: some View {
        Button {
            @Bindable var model = model
            model.showEditTaskIDAlert = true
        } label: {
            StatusBarLabel(text: model.taskID)
                .frame(maxWidth: maxSideWidth, alignment: .trailing)
        }
        .foregroundStyle(.white)
    }

    var ldap: some View {
        StatusBarLabel(text: model.ldap)
            .frame(maxWidth: maxSideWidth, alignment: .leading)
    }
}

#Preview {
    let model = Model()
    model.taskID = "id"
    model.ldap = "suraj"
    return StatusBar()
        .environment(model)
}
