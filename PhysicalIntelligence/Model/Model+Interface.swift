//
//  Model+Interface.swift
//  PhysicalIntelligence
//
//  Created by Benjamin Sage on 9/28/24.
//

import Foundation

extension Model {
    func toggleRecording() {
        if isRecording {
            isRecording = false
            recordingTime = 0
            session.pause()
            saveRecording()
            currentRecording = nil
            timerCancellable?.cancel()
            timerCancellable = nil
        } else {
            startARSession()
            currentRecording = RecordingData(frames: [])
            currentRecording?.startTime = Date()
            isRecording = true
            recordingTime = 0
            timerCancellable = Timer.publish(every: 0.1, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] _ in
                    Task { @MainActor in
                        if let startTime = self?.currentRecording?.startTime {
                            self?.recordingTime = Date().timeIntervalSince(startTime)
                        }
                    }
                }
        }
    }

    func ldapDone() {
        showSettingsSheet = false
        showLDAPSheet = false
    }
}
