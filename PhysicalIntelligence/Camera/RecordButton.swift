//
//  RecordButton.swift
//  PhysicalIntelligence
//
//  Created by Benjamin Sage on 9/22/24.
//

import SwiftUI

struct RecordButton: View {
    @State private var isRecording: Bool = false

    var width: CGFloat = 60
    var lineWidth: CGFloat = 4
    var spacing: CGFloat = 2

    var circleWidth: CGFloat {
        width + lineWidth + spacing * 2
    }

    var body: some View {
        ZStack {
            // White outer circle
            Circle()
                .stroke(Color.white, lineWidth: lineWidth)
                .frame(width: circleWidth, height: circleWidth)

            RoundedRectangle(cornerRadius: isRecording ? 8 : 30)
                .fill(Color.red)
                .padding(isRecording ? 15 : 0)
                .frame(width: 60, height: 60)
                .animation(.snappy(duration: 1/3), value: isRecording)
        }
        .onTapGesture {
            isRecording.toggle() // Toggle recording state
        }
    }
}

#Preview {
    RecordButton()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Color.black.ignoresSafeArea()
        }
}
