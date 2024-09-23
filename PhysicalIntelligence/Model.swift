//
//  Model.swift
//  PhysicalIntelligence
//
//  Created by Benjamin Sage on 9/22/24.
//

import Foundation

public class Model: ObservableObject {
    @Published var showSettingsSheet = false
    @Published var showLDAP = false

    @Published var ldap = ""
    @Published var taskID = ""

    @Published var onboardingPath: [OnboardingPage] = []
}
