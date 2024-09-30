//
//  UploadRowView.swift
//  PhysicalIntelligence
//
//  Created by Benjamin Sage on 9/29/24.
//

import SwiftUI
import SageKit

struct UploadRowView: View {
    var upload: RecordingUpload

    @State var uiImage: UIImage?

    var body: some View {
        HStack {
            Color.clear
                .overlay {
                    if let uiImage {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                    }
                }
                .frame(width: 50, height: 50)
                .onAppear {
                    uiImage = UIImage(data: upload.thumbnailData)
                }
                .loadingOverlay(Int(upload.progress * 100), done: false)
                .clipShape(RoundedRectangle(cornerRadius: 6))

            VStack(alignment: .leading) {
                Text(upload.taskID)
                Text("Progress: \(Int(upload.progress * 100))%")
                    .font(.subtitle)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }
}

#Preview {
    UploadRowView(upload: .sample)
}
