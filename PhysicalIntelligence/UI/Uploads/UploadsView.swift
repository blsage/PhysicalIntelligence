//
//  UploadsView.swift
//  PhysicalIntelligence
//
//  Created by Benjamin Sage on 9/29/24.
//

import SwiftUI

struct UploadsView: View {
    @Environment(\.model) var model

    var body: some View {
        List(model.uploads) { upload in
            UploadRowView(upload: upload)
        }
    }
}

#Preview {
    UploadsView()
        .environment(Model())
}
