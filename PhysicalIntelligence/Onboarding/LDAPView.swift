//
//  LDAPView.swift
//  PhysicalIntelligence
//
//  Created by Benjamin Sage on 9/23/24.
//

import SwiftUI

struct LDAPView: View {
    @Environment(\.model) var model

    @FocusState private var focused: Bool

    var body: some View {
        @Bindable var model = model
        VStack(spacing: 30) {
            Text("What’s your LDAP?")
                .font(.largeTitle.weight(.bold))
            Text("This will be used to identify you to your uploads and authenticate server connection.")
                .multilineTextAlignment(.center)

            TextField("surajnair", text: $model.ldap)
                .monospaced()
                .padding(.vertical)
                .padding(.horizontal)
                .submitLabel(.next)
                .textInputAutocapitalization(.never)
                .textContentType(.username)
                .onSubmit(next)
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
            Button("Next", action: next)            .buttonStyle(StretchedButtonStyle())
                .disabled(model.ldap.count < 3)
                .foregroundStyle(.white, .blurple)
        }
        .padding(.top, 24)
        .padding(28)
        .frame(maxWidth: .infinity)
    }

    func next() {
        model.ldapDone()
    }
}

#Preview {
    LDAPView()
        .environment(Model())
}
