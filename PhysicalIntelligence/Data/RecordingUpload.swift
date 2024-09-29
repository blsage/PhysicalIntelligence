//
//  RecordingUpload.swift
//  PhysicalIntelligence
//
//  Created by Benjamin Sage on 9/29/24.
//

import Foundation
import CoreLocation
import UIKit

enum UploadStatus: Codable {
    case pending
    case uploading
    case completed
    case failed(String) // Store error description

    enum CodingKeys: String, CodingKey {
        case type
        case errorDescription
    }

    // Custom encoding and decoding to handle associated values
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .pending:
            try container.encode("pending", forKey: .type)
        case .uploading:
            try container.encode("uploading", forKey: .type)
        case .completed:
            try container.encode("completed", forKey: .type)
        case .failed(let error):
            try container.encode("failed", forKey: .type)
            try container.encode(error, forKey: .errorDescription)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "pending":
            self = .pending
        case "uploading":
            self = .uploading
        case "completed":
            self = .completed
        case "failed":
            let errorDescription = try container.decode(String.self, forKey: .errorDescription)
            self = .failed(errorDescription)
        default:
            self = .pending
        }
    }
}

class RecordingUpload: Identifiable, Codable {
    let id: UUID
    let recordingID: String
    var progress: Double
    let thumbnailData: Data
    let taskID: String
    let location: CLLocationCoordinate2D?
    var status: UploadStatus

    enum CodingKeys: CodingKey {
        case id, recordingID, progress, thumbnailData, taskID, location, status
    }

    init(recordingID: String, thumbnail: UIImage, taskID: String, location: CLLocationCoordinate2D?) {
        self.id = UUID()
        self.recordingID = recordingID
        self.thumbnailData = thumbnail.jpegData(compressionQuality: 0.8) ?? Data()
        self.taskID = taskID
        self.location = location
        self.status = .pending
        self.progress = 0.0
    }

    // Custom initializer for decoding
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.recordingID = try container.decode(String.self, forKey: .recordingID)
        self.progress = try container.decode(Double.self, forKey: .progress)
        self.thumbnailData = try container.decode(Data.self, forKey: .thumbnailData)
        self.taskID = try container.decode(String.self, forKey: .taskID)
        self.location = try container.decodeIfPresent(CLLocationCoordinate2D.self, forKey: .location)
        self.status = try container.decode(UploadStatus.self, forKey: .status)
    }

    // Custom encoding is not needed since all properties are Codable
}

extension RecordingUpload {
    var thumbnail: UIImage {
        return UIImage(data: self.thumbnailData) ?? UIImage(systemName: "photo")!
    }
}

// MARK: - Sample

extension RecordingUpload {
    static let sample = RecordingUpload(
        recordingID: "SampleRecording123",
        thumbnail: UIImage(systemName: "camera")!,
        taskID: "SampleTask456",
        location: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
    )
}
