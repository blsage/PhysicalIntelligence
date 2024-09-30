//
//  Model+Uploads.swift
//  PhysicalIntelligence
//
//  Created by Benjamin Sage on 9/29/24.
//

import Foundation
import UIKit
import AVKit

extension Model {
    func uploadRecording() {
        guard let recording = currentRecording else {
            print("Tried to upload recording with nil currentRecording")
            return
        }

        Task {
            let recordingID = UUID().uuidString

            guard let recordingFolderURL = await self.client.saveRecordingToFiles(
                recording, recordingID: recordingID, ldap: self.ldap, location: self.currentLocation
            ) else {
                print("Failed to save recording to files")
                return
            }

            let thumbnail = await self.client.generateThumbnail(from: recording)

            let upload = RecordingUpload(
                recordingID: recordingID,
                thumbnail: thumbnail,
                taskID: self.taskID,
                location: self.currentLocation
            )

            self.uploads.insert(upload, at: 0)

            await client.uploadFiles(recordingFolderURL: recordingFolderURL, upload: upload, ldap: ldap)
        }
    }

    func resumePendingUploads() {
        for upload in uploads {
            switch upload.status {
            case .pending, .uploading:
                Task {
                    await client.resumeUpload(upload, ldap: ldap)
                }
            default:
                continue
            }
        }
    }
}

struct Metadata: Codable {
    let userID: String
    let recordingID: String
    let location: Location?
    let timestamp: Date
    let deviceInfo: DeviceInfo
}

struct Location: Codable {
    let latitude: Double?
    let longitude: Double?
}

struct DeviceInfo: Codable {
    let model: String
    let osVersion: String
}

struct SLAMFrame: Codable {
    let timestamp: TimeInterval
    let cameraTransform: [Float]
}
