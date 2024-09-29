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

@Observable class Model: NSObject {
    var welcomeShown: Bool = false // persist
    var showSettingsSheet = false
    var showUploadsSheet = false
    var showLDAPSheet = false
    var showLDAP = false
    var ldap = "" // persist
    var taskID = ""
    var showLogoutConfirmation = false
    var showSetTaskIDAlert = false
    var showEditTaskIDAlert = false
    var recordingTime: TimeInterval = 0
    var isRecording = false
    var lastFrame: TimeInterval = 0

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
    }

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    private var uploadsFileURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("uploads.json")
    }

    func saveRecording() {
        guard let recording = currentRecording, let modelContext = modelContext else { return }
        do {
//            modelContext.insert(recording)
            try modelContext.save()
            print("Recording saved successfully.")
        } catch {
            print("Error saving recording: \(error)")
        }
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
