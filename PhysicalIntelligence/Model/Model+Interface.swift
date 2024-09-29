//
//  Model+Interface.swift
//  PhysicalIntelligence
//
//  Created by Benjamin Sage on 9/28/24.
//

import Foundation
import Combine

extension Model {
    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    func startRecording() {
        startARSession()
        currentRecording = RecordingData(frames: [])
        currentRecording?.startTime = Date()
        isRecording = true
        recordingTime = 0
        timerCancellable = recordingTimer
    }

    func stopRecording() {
        isRecording = false
        recordingTime = 0
        session.pause()
        saveRecording()
        currentRecording = nil
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    var recordingTimer: AnyCancellable {
        Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task { @MainActor in
                    if let startTime = self?.currentRecording?.startTime {
                        self?.recordingTime = Date().timeIntervalSince(startTime)
                    }
                }
            }
    }

    func ldapDone() {
        showSettingsSheet = false
        showLDAPSheet = false
    }

    func tryStartRecording() {
        if taskID.isEmpty {
            showTaskIDAlert = true
        } else {
            toggleRecording()
        }
    }

    func showAppropriateSheet() {
        if !welcomeShown {
            showSettingsSheet = true
        } else if ldap.isEmpty {
            showLDAPSheet = true
        }
    }
}
