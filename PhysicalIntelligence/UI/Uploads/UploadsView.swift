//
//  UploadsView.swift
//  PhysicalIntelligence
//
//  Created by Benjamin Sage on 9/29/24.
//

import SwiftUI

struct UploadsView: View {
    @Environment(\.model) var model
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List(model.uploads) { upload in
                UploadRowView(upload: upload)
            }
            .listStyle(.plain)
            .navigationTitle("Uploads")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close", systemImage: "xmark") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    UploadsView()
        .environment(Model())
}
