//
//  TimeLabel.swift
//  PhysicalIntelligence
//
//  Created by Benjamin Sage on 9/22/24.
//

import SwiftUI

struct TimeLabel: View {
    @Environment(\.model) var model

    var duration: TimeInterval {
        model.recordingTime
    }

    var time: String {
        let hours = Int(duration / 3600)
        let minutes = Int(duration.truncatingRemainder(dividingBy: 3600) / 60)
        let secs = Int(duration.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d:%02d", hours, minutes, secs)
    }

    var body: some View {
        Text(time)
            .font(.title3)
            .monospacedDigit()
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .background {
                RoundedRectangle(cornerRadius: 4)
                    .fill(model.isRecording ? .red : .clear)
                    .animation(.default.delay(0.4), value: model.isRecording)
            }
    }
}

#Preview {
    TimeLabel()
        .environment(Model())
}
