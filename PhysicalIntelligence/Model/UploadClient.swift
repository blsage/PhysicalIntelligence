//
//  UploadClient.swift
//  PhysicalIntelligence
//
//  Created by Benjamin Sage on 9/29/24.
//

import Foundation
import UIKit
import AVKit
import CoreLocation

class UploadClient {
    lazy var customSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 120
        configuration.timeoutIntervalForResource = 300
        configuration.httpMaximumConnectionsPerHost = 100
        return URLSession(configuration: configuration)
    }()

    func saveRecordingToFiles(
        _ recording: RecordingData,
        recordingID: String,
        ldap: String,
        location: CLLocationCoordinate2D?
    ) async -> URL? {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let recordingFolderURL = documentsDirectory.appendingPathComponent("recording_\(recordingID)")

        do {
            try fileManager.createDirectory(at: recordingFolderURL, withIntermediateDirectories: true)

            let videoFolderURL = recordingFolderURL.appendingPathComponent("video")
            try fileManager.createDirectory(at: videoFolderURL, withIntermediateDirectories: true)
            try await saveVideoData(frames: recording.frames, to: videoFolderURL)

            let depthFolderURL = recordingFolderURL.appendingPathComponent("depth")
            try fileManager.createDirectory(at: depthFolderURL, withIntermediateDirectories: true)
            try await saveDepthData(frames: recording.frames, to: depthFolderURL)

            let slamDataURL = recordingFolderURL.appendingPathComponent("slam_data.json")
            try saveSLAMData(frames: recording.frames, to: slamDataURL)

            let metadataURL = recordingFolderURL.appendingPathComponent("metadata.json")
            try await saveMetadata(
                recording: recording, to: metadataURL, recordingID: recordingID, ldap: ldap, location: location
            )

            return recordingFolderURL
        } catch {
            print("Error saving recording to files: \(error)")
            return nil
        }
    }

    private func saveVideoData(frames: [RecordedFrame], to folderURL: URL) async throws {
        var frameIndex = 0

        for frame in frames {
            let depthImageURL = folderURL.appendingPathComponent(String(format: "frame%04d.jpeg", frameIndex))
            try frame.imageData.write(to: depthImageURL)
            frameIndex += 1
        }
    }

    private func saveDepthData(frames: [RecordedFrame], to folderURL: URL) async throws {
        var frameIndex = 0

        for frame in frames {
            if let depthData = frame.depthData {
                let depthImageURL = folderURL.appendingPathComponent(String(format: "frame%04d.jpeg", frameIndex))
                try depthData.write(to: depthImageURL)
            }
            frameIndex += 1
            try await Task.sleep(nanoseconds: 1_000_000)
        }
    }

    func saveSLAMData(frames: [RecordedFrame], to url: URL) throws {
        let slamFrames = frames.map { frame in
            return SLAMFrame(timestamp: frame.timestamp, cameraTransform: frame.cameraTransform)
        }
        let data = try JSONEncoder().encode(slamFrames)
        try data.write(to: url)
    }

    @MainActor
    func saveMetadata(
        recording: RecordingData,
        to url: URL,
        recordingID: String,
        ldap: String,
        location: CLLocationCoordinate2D?
    ) throws {
        let metadata = Metadata(
            userID: ldap,
            recordingID: recordingID,
            location: Location(latitude: location?.latitude, longitude: location?.longitude),
            timestamp: recording.startTime ?? Date(),
            deviceInfo: DeviceInfo(model: UIDevice.current.model, osVersion: UIDevice.current.systemVersion)
        )

        let data = try JSONEncoder().encode(metadata)
        try data.write(to: url)
    }

    func generateThumbnail(from recording: RecordingData) -> UIImage {
        guard let firstFrame = recording.frames.first else {
            print("Recording has no frames")
            return UIImage(systemName: "photo")!
        }

        guard let image = UIImage(data: firstFrame.imageData) else {
            print("couldn't get image data")
            return UIImage(systemName: "photo")!
        }

        return image
    }

    func uploadFiles(recordingFolderURL: URL, upload: RecordingUpload, ldap: String) async {
        let fileManager = FileManager.default
        guard let enumerator = fileManager.enumerator(at: recordingFolderURL, includingPropertiesForKeys: nil) else {
            print("Failed to enumerate files for upload.")
            return
        }

        var filesToUpload: [URL] = []
        for case let fileURL as URL in enumerator {
            if fileURL.hasDirectoryPath {
                continue
            }
            filesToUpload.append(fileURL)
        }

        guard let urlMapping = await requestPresignedURLs(
            for: filesToUpload, recordingID: upload.recordingID, ldap: ldap
        ) else {
            DispatchQueue.main.async {
                upload.status = .failed("Failed to get pre-signed URLs")
            }
            return
        }

        await uploadFiles(filesToUpload, urlMapping: urlMapping, upload: upload)
    }

    func requestPresignedURLs(for files: [URL], recordingID: String, ldap: String) async -> [URL: URL]? {
        guard let recordingFolderURL = files.first?.deletingLastPathComponent() else {
            print("Recording folder URL could not be determined.")
            return nil
        }

        let fileKeys = files.compactMap { fileURL -> String? in
            let relativePath = fileURL.path.replacingOccurrences(of: recordingFolderURL.path + "/", with: "")

            let cleanedRelativePath = relativePath.hasPrefix("/") ? String(relativePath.dropFirst()) : relativePath

            return "\(ldap.trimmingCharacters(in: .whitespacesAndNewlines))/\(recordingID)/\(cleanedRelativePath)"
        }

        guard let url = URL(string: "https://physical-intelligence-workers.vercel.app/presigned-urls") else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let parameters = ["fileKeys": fileKeys]
        request.httpBody = try? JSONEncoder().encode(parameters)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 120 // Increased timeout

        do {
            let (data, response) = try await customSession.data(for: request)
            print("Received response for pre-signed URLs request: \(response)")

            let decoder = JSONDecoder()
            let responseDict = try decoder.decode([String: String].self, from: data)
            var urlMapping: [URL: URL] = [:]
            for (fileKey, urlString) in responseDict {
                if let presignedURL = URL(string: urlString),
                   let fileURL = files.first(where: { fileKey.hasSuffix($0.lastPathComponent) }) {
                    urlMapping[fileURL] = presignedURL
                }
            }
            return urlMapping
        } catch {
            print("Error requesting pre-signed URLs: \(error)")
            return nil
        }
    }

    func uploadFiles(_ files: [URL], urlMapping: [URL: URL], upload: RecordingUpload) async {
        var uploadErrors: [Error] = []
        var totalBytesSent: Int64 = 0
        var totalBytesExpectedToSend: Int64 = 0
        let maxConcurrentUploads = 10

        print("Starting upload for \(files.count) files")

        for fileURL in files {
            if let fileSize = try? FileManager.default.attributesOfItem(atPath: fileURL.path)[.size] as? Int64 {
                totalBytesExpectedToSend += fileSize
            } else {
                print("Could not retrieve file size for \(fileURL.lastPathComponent)")
            }
        }

        print("Total bytes expected to send: \(totalBytesExpectedToSend)")

        let batches = stride(from: 0, to: files.count, by: maxConcurrentUploads).map {
            Array(files[$0..<min($0 + maxConcurrentUploads, files.count)])
        }

        for batch in batches {
            await withTaskGroup(of: (Int64, Error?).self) { group in
                for fileURL in batch {
                    guard let presignedURL = urlMapping[fileURL] else {
                        print("No pre-signed URL found for \(fileURL.lastPathComponent)")
                        continue
                    }

                    group.addTask {
                        do {
                            var request = URLRequest(url: presignedURL)
                            request.httpMethod = "PUT"
                            request.timeoutInterval = 120 // Ensure timeout is set

                            let fileData = try Data(contentsOf: fileURL)

                            let (_, response) = try await self.customSession.upload(for: request, from: fileData)

                            if let httpResponse = response as? HTTPURLResponse {
                                print("Response status code for \(fileURL.lastPathComponent): \(httpResponse.statusCode)")
                                if httpResponse.statusCode != 200 {
                                    let error = NSError(
                                        domain: "Upload",
                                        code: httpResponse.statusCode,
                                        userInfo: [
                                            NSLocalizedDescriptionKey: "Failed to upload \(fileURL.lastPathComponent)"
                                        ]
                                    )
                                    print(error.localizedDescription)
                                    return (Int64(fileData.count), error)
                                } else {
                                    print("Successfully uploaded \(fileURL.lastPathComponent)")
                                    return (Int64(fileData.count), nil)
                                }
                            } else {
                                print("Unexpected response type for \(fileURL.lastPathComponent)")
                                return (
                                    Int64(fileData.count),
                                    NSError(
                                        domain: "Upload",
                                        code: 0,
                                        userInfo: [NSLocalizedDescriptionKey: "Unexpected response type"]
                                    )
                                )
                            }
                        } catch {
                            print("Error uploading \(fileURL.lastPathComponent): \(error.localizedDescription)")
                            return (0, error)
                        }
                    }
                }

                // Process task results
                for await (bytesSent, error) in group {
                    totalBytesSent += bytesSent
                    let progress: Double
                    if totalBytesExpectedToSend > 0 {
                        progress = Double(totalBytesSent) / Double(totalBytesExpectedToSend)
                    } else {
                        progress = 1.0
                    }

                    await MainActor.run {
                        upload.progress = progress
                        // Optionally, you can also notify the UI here if needed
                    }

                    if let error = error {
                        uploadErrors.append(error)
                    }
                }
            }
        }

        // Finalize upload status
        if uploadErrors.isEmpty {
            await MainActor.run {
                upload.status = .completed
                upload.progress = 1.0
                self.cleanupRecordingFiles(recordingID: upload.recordingID)
            }
        } else {
            await MainActor.run {
                let errorDescription = uploadErrors.first?.localizedDescription ?? "Unknown error"
                print("Upload failed with error: \(errorDescription)")
                upload.status = .failed(errorDescription)
            }
        }
    }

    func cleanupRecordingFiles(recordingID: String) {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let recordingFolderURL = documentsDirectory.appendingPathComponent("recording_\(recordingID)")

        do {
            try fileManager.removeItem(at: recordingFolderURL)
        } catch {
            print("Failed to remove recording files: \(error)")
        }
    }

    func resumeUpload(_ upload: RecordingUpload, ldap: String) async {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let recordingFolderURL = documentsDirectory.appendingPathComponent("recording_\(upload.recordingID)")

        guard fileManager.fileExists(atPath: recordingFolderURL.path) else {
            await MainActor.run {
                upload.status = .failed("Recording files not found.")
            }
            return
        }

        await uploadFiles(recordingFolderURL: recordingFolderURL, upload: upload, ldap: ldap)
    }
}
