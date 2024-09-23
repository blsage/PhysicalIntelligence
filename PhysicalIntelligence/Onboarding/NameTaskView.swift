//
//  NameTaskView.swift
//  PhysicalIntelligence
//
//  Created by Benjamin Sage on 9/23/24.
//

import SwiftUI

struct NameTaskView: View {
    @EnvironmentObject var model: Model

    @FocusState var focused: Bool

    var body: some View {
        VStack(spacing: 30) {
            Text("Name your task")
                .font(.largeTitle.weight(.bold))
            Text("Give your initial task a name. Names can't have spaces and must be between 3-24 characters.")
                .multilineTextAlignment(.center)

            TextField("e.g. put_away_dishes", text: $model.taskID)
                .monospaced()
                .padding(.vertical)
                .padding(.horizontal)
                .submitLabel(.done)
                .textInputAutocapitalization(.never)
                .textContentType(.username)
                .onSubmit(done)
                .focused($focused)
                .background {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.quinary)
                }
                .onAppear {
                    focused = true
                }

            Spacer()

        }
        .overlay(alignment: .bottom) {
            Button("Done", action: done)            .buttonStyle(StretchedButtonStyle())
                .disabled(model.taskID.count < 3)
                .foregroundStyle(.white, .blurple)
        }
        .padding(.top, 24)
        .padding(28)
        .frame(maxWidth: .infinity)
    }

    func done() {
        model.showSettingsSheet = false
    }
}

#Preview {
    NameTaskView()
        .environmentObject(Model())
}
