//
//  EnvironmentValues+Model.swift
//  PhysicalIntelligence
//
//  Created by Benjamin Sage on 9/28/24.
//

import SwiftUI

struct ModelEnvironmentValue: @preconcurrency EnvironmentKey {
    @MainActor
    static let defaultValue: Model = .init()
}

extension EnvironmentValues {
    var model: Model {
        get { self[ModelEnvironmentValue.self] }
        set { self[ModelEnvironmentValue.self] = newValue }
    }
}
