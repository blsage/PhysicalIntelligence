//
//  Model.swift
//  PhysicalIntelligence
//
//  Created by Benjamin Sage on 9/22/24.
//

import Foundation
import ARKit
import SwiftData
import SwiftUI
import Combine
import UIKit
import SageKit

@MainActor @Observable class Model: NSObject {
    var welcomeShown: Bool = false {
        didSet { welcomeShown.save("welcomeShown") }
    }
    var showSettingsSheet = false
    var showUploadsSheet = false
    var showLDAPSheet = false
    var showLDAP = false
    var ldap = "" {
        didSet { ldap.save("ldap") }
    }
    var taskID = "" {
        didSet { taskID.save("taskID") }
    }
    var showLogoutConfirmation = false
    var showSetTaskIDAlert = false
    var showEditTaskIDAlert = false
    var recordingTime: TimeInterval = 0
    var isRecording = false

    var uploads: [RecordingUpload] = [] {
        didSet {
            saveUploads()
        }
    }

    var timerCancellable: AnyCancellable?

    var session = ARSession()
    var currentRecording: RecordingData?
    var modelContext: ModelContext?

    var locationManager: CLLocationManager?
    var locationUpdateContinuation: CheckedContinuation<Void, Error>?
    var currentLocation: CLLocationCoordinate2D?

    override init() {
        super.init()
        loadUploads()
        resumePendingUploads()
        welcomeShown = Bool.load("welcomeShown") ?? false
        ldap = String.load("ldap") ?? ""
        taskID = String.load("taskID") ?? ""
    }

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    private var uploadsFileURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("uploads.json")
    }

    func saveUploads() {
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try JSONEncoder().encode(self.uploads)
                try data.write(to: self.uploadsFileURL)
            } catch {
                print("Failed to save uploads: \(error)")
            }
        }
    }

    func loadUploads() {
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try Data(contentsOf: self.uploadsFileURL)
                let uploads = try JSONDecoder().decode([RecordingUpload].self, from: data)
                DispatchQueue.main.async {
                    self.uploads = uploads
                }
            } catch {
                print("Failed to load uploads: \(error)")
            }
        }
    }

}
