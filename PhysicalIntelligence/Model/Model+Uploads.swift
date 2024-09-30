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

        Task(priority: .userInitiated) {
            let recordingID = UUID().uuidString

            guard let recordingFolderURL = await saveRecordingToFiles(recording, recordingID: recordingID) else {
                print("Failed to save recording to files")
                return
            }

            let thumbnail = generateThumbnail(from: recording)

            let upload = RecordingUpload(
                recordingID: recordingID,
                thumbnail: thumbnail,
                taskID: self.taskID,
                location: self.currentLocation
            )

            Task { @MainActor in
                uploads.insert(upload, at: 0)
            }

            await uploadFiles(recordingFolderURL: recordingFolderURL, upload: upload)
        }
    }

    func saveRecordingToFiles(_ recording: RecordingData, recordingID: String) async -> URL? {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let recordingFolderURL = documentsDirectory.appendingPathComponent("recording_\(recordingID)")

        do {
            try fileManager.createDirectory(at: recordingFolderURL, withIntermediateDirectories: true, attributes: nil)

            let videoURL = recordingFolderURL.appendingPathComponent("video.mp4")
            try await saveVideo(frames: recording.frames, to: videoURL)

            let depthFolderURL = recordingFolderURL.appendingPathComponent("depth")
            try fileManager.createDirectory(at: depthFolderURL, withIntermediateDirectories: true, attributes: nil)
            try await saveDepthData(frames: recording.frames, to: depthFolderURL)

            let slamDataURL = recordingFolderURL.appendingPathComponent("slam_data.json")
            try saveSLAMData(frames: recording.frames, to: slamDataURL)

            let metadataURL = recordingFolderURL.appendingPathComponent("metadata.json")
            try saveMetadata(recording: recording, to: metadataURL, recordingID: recordingID)

            return recordingFolderURL
        } catch {
            print("Error saving recording to files: \(error)")
            return nil
        }
    }

    func saveVideo(frames: [RecordedFrame], to url: URL) async throws {
        guard let firstFrame = frames.first,
              let image = UIImage(data: firstFrame.imageData) else {
            print("No frames to save for video.")
            return
        }

        let frameSize = image.size
        let fps: Int32 = 30 // Adjust as needed

        let videoWriter = try AVAssetWriter(outputURL: url, fileType: .mp4)
        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: frameSize.width,
            AVVideoHeightKey: frameSize.height
        ]
        let writerInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        writerInput.expectsMediaDataInRealTime = false

        let adaptor = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: writerInput,
            sourcePixelBufferAttributes: nil
        )

        guard videoWriter.canAdd(writerInput) else {
            print("Cannot add writer input to video writer")
            return
        }

        videoWriter.add(writerInput)

        videoWriter.startWriting()
        videoWriter.startSession(atSourceTime: .zero)

        var frameCount = 0

        for frame in frames {
            if writerInput.isReadyForMoreMediaData {
                autoreleasepool {
                    if let image = UIImage(data: frame.imageData),
                       let pixelBuffer = self.pixelBufferFromImage(image: image.cgImage!) {
                        let presentationTime = CMTime(value: CMTimeValue(frameCount), timescale: fps)
                        adaptor.append(pixelBuffer, withPresentationTime: presentationTime)
                        frameCount += 1
                    }
                }
            } else {
                // Wait until writerInput is ready
                try await Task.sleep(nanoseconds: 10_000_000) // Wait for 10 milliseconds
            }
        }

        writerInput.markAsFinished()
        await videoWriter.finishWriting()

        print("Video writing finished.")
    }

    func pixelBufferFromImage(image: CGImage) -> CVPixelBuffer? {
        let frameSize = CGSize(width: image.width, height: image.height)
        var pixelBuffer: CVPixelBuffer?

        let options: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
        ]

        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            Int(frameSize.width),
            Int(frameSize.height),
            kCVPixelFormatType_32ARGB,
            options as CFDictionary,
            &pixelBuffer
        )

        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }

        CVPixelBufferLockBaseAddress(buffer, [])
        let pxData = CVPixelBufferGetBaseAddress(buffer)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()

        guard let context = CGContext(
            data: pxData,
            width: Int(frameSize.width),
            height: Int(frameSize.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: rgbColorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        ) else {
            CVPixelBufferUnlockBaseAddress(buffer, [])
            return nil
        }

        context.draw(image, in: CGRect(origin: .zero, size: frameSize))
        CVPixelBufferUnlockBaseAddress(buffer, [])
        return buffer
    }

    func saveDepthData(frames: [RecordedFrame], to folderURL: URL) async throws {
        var frameIndex = 0

        for frame in frames {
            if let depthData = frame.depthData {
                let depthImage = UIImage(data: depthData)
                let depthImageURL = folderURL.appendingPathComponent(String(format: "frame%04d.png", frameIndex))
                if let pngData = depthImage?.pngData() {
                    try pngData.write(to: depthImageURL)
                }
            }
            frameIndex += 1
            // Optional: Add a small delay if necessary
            try await Task.sleep(nanoseconds: 1_000_000) // 1 millisecond
        }
    }

    func saveSLAMData(frames: [RecordedFrame], to url: URL) throws {
        let slamFrames = frames.map { frame in
            return SLAMFrame(timestamp: frame.timestamp, cameraTransform: frame.cameraTransform)
        }
        let data = try JSONEncoder().encode(slamFrames)
        try data.write(to: url)
    }

    func saveMetadata(recording: RecordingData, to url: URL, recordingID: String) throws {
        let metadata = Metadata(
            userID: self.ldap,
            recordingID: recordingID,
            location: Location(latitude: self.currentLocation?.latitude, longitude: self.currentLocation?.longitude),
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

    func uploadFiles(recordingFolderURL: URL, upload: RecordingUpload) async {
        // Enumerate all files in the recording folder
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

        // Request pre-signed URLs for each file
        guard let urlMapping = await requestPresignedURLs(for: filesToUpload, recordingID: upload.recordingID) else {
            DispatchQueue.main.async {
                upload.status = .failed("Failed to get pre-signed URLs")
            }
            return
        }

        // Start uploading files
        await uploadFiles(filesToUpload, urlMapping: urlMapping, upload: upload)
    }

    func requestPresignedURLs(for files: [URL], recordingID: String) async -> [URL: URL]? {
        // Prepare the list of file paths relative to the recording folder
        let recordingFolderPath = files.first?.deletingLastPathComponent().path ?? ""
        let fileKeys = files.map { fileURL -> String in
            let relativePath = fileURL.path.replacingOccurrences(of: recordingFolderPath + "/", with: "")
            return "\(self.ldap)/\(recordingID)/\(relativePath)"
        }

        // Replace with your server URL that provides pre-signed URLs
        guard let url = URL(string: "https://physical-intelligence-workers.vercel.app") else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let parameters = ["fileKeys": fileKeys]
        request.httpBody = try? JSONEncoder().encode(parameters)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            let responseDict = try decoder.decode([String: String].self, from: data)
            // responseDict maps fileKey to presignedURL
            var urlMapping: [URL: URL] = [:]
            for (fileKey, urlString) in responseDict {
                if let fileURL = files.first(where: { fileURL in
                    let relativePath = fileURL.path.replacingOccurrences(of: recordingFolderPath + "/", with: "")
                    return relativePath == fileKey
                }), let presignedURL = URL(string: urlString) {
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

        // Calculate total expected bytes
        for fileURL in files {
            if let fileSize = try? FileManager.default.attributesOfItem(atPath: fileURL.path)[.size] as? Int64 {
                totalBytesExpectedToSend += fileSize
            }
        }

        await withTaskGroup(of: (Int64, Error?).self) { group in
            for fileURL in files {
                guard let presignedURL = urlMapping[fileURL] else {
                    continue
                }

                group.addTask {
                    do {
                        var request = URLRequest(url: presignedURL)
                        request.httpMethod = "PUT"

                        let fileData = try Data(contentsOf: fileURL)
                        let (response, _) = try await URLSession.shared.upload(for: request, from: fileData)

                        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                            let error = NSError(
                                domain: "Upload",
                                code: httpResponse.statusCode,
                                userInfo: [NSLocalizedDescriptionKey: "Failed to upload \(fileURL.lastPathComponent)"]
                            )
                            return (Int64(fileData.count), error)
                        } else {
                            return (Int64(fileData.count), nil)
                        }
                    } catch {
                        return (0, error)
                    }
                }
            }

            for await (bytesSent, error) in group {
                totalBytesSent += bytesSent
                let progress = Double(totalBytesSent) / Double(totalBytesExpectedToSend)
                DispatchQueue.main.async {
                    upload.progress = progress
                }
                if let error = error {
                    uploadErrors.append(error)
                }
            }
        }

        if uploadErrors.isEmpty {
            DispatchQueue.main.async {
                upload.status = .completed
                upload.progress = 1.0
                self.cleanupRecordingFiles(recordingID: upload.recordingID)
            }
        } else {
            DispatchQueue.main.async {
                let errorDescription = uploadErrors.first?.localizedDescription ?? "Unknown error"
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

    func resumePendingUploads() {
        for upload in uploads {
            switch upload.status {
            case .pending, .uploading:
                Task {
                    await self.resumeUpload(upload)
                }
            default:
                continue
            }
        }
    }

    func resumeUpload(_ upload: RecordingUpload) async {
        // Locate the recording folder in the temporary directory
        let tempDirectory = FileManager.default.temporaryDirectory
        let recordingFolderURL = tempDirectory.appendingPathComponent("recording_\(upload.recordingID)")

        // Check if the folder exists; if not, handle error
        guard FileManager.default.fileExists(atPath: recordingFolderURL.path) else {
            DispatchQueue.main.async {
                upload.status = .failed("Recording files not found.")
            }
            return
        }

        // Resume uploading files
        await uploadFiles(recordingFolderURL: recordingFolderURL, upload: upload)
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
