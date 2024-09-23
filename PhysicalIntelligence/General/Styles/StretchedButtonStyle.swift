//
//  StretchedButtonStyle.swift
//  PhysicalIntelligence
//
//  Created by Benjamin Sage on 9/23/24.
//

import SwiftUI
import BenKit

struct StretchedButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled

    enum Size { case stretched, regular }
    var size: Size
    @Binding var loading: Bool
    var haptics: Bool

    @State var hapticToggle = false

    init(
        _ size: Size = .stretched, loading: Binding<Bool> = .constant(false),
        haptics: Bool = true
    ) {
        self.size = size
        self._loading = loading
        self.haptics = haptics
    }

    @State private var lastTap: Date?
    @State private var isExpanded: Bool = false

    func showPressed(_ isPressed: Bool) -> Bool {
        isExpanded || isPressed
    }

    var animationDuration: CGFloat = 0.15

    var animation: Animation {
        .smooth(duration: animationDuration)
    }

    var stretched: Bool {
        size == .stretched
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.primary)
            .font(.headline)
            .frame(maxWidth: stretched ? .infinity : nil)
            .padding(.vertical, 17)
            .padding(.horizontal, 24)
            .opacity(loading ? 0 : 1)
            .background {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.secondary)
            }
            .overlay {
                if loading {
                    ProgressView()
                        .frame(width: 40, height: 40)
                        .foregroundStyle(.primary)
                }
            }
            .scaleEffect(showPressed(configuration.isPressed) ? 1.05 : 1.0)
            .animation(animation, value: showPressed(configuration.isPressed))
            .onChange(of: configuration.isPressed) {
                handlePressed(configuration.isPressed)
            }
            .sensoryFeedback(.impact(flexibility: .soft), trigger: hapticToggle)
            .foregroundStyle(primaryForegroundStyle, secondaryForegroundStyle)
    }

    var primaryForegroundStyle: some ShapeStyle {
        isEnabled ? Color.white : .secondary
    }

    var secondaryForegroundStyle: some ShapeStyle {
        isEnabled ? Color.blurple : .secondary.opacity(0.5)
    }

    func handlePressed(_ isPressed: Bool) {
        if isPressed {
            isExpanded = true
            lastTap = Date()
            if haptics {
                hapticToggle.toggle()
            }
        } else {
            let timeSinceLastTap = lastTap.map {
                Date().timeIntervalSince($0)
            } ?? 0
            let delay = max(0, animationDuration - timeSinceLastTap)

            Task {
                try? await Task.sleep(for: .seconds(delay))
                isExpanded = false
            }
        }
    }
}
