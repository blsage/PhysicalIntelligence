//
//  RecordingData.swift
//  PhysicalIntelligence
//
//  Created by Benjamin Sage on 9/29/24.
//

import SwiftData
import Foundation
import UIKit

class RecordingData: Identifiable, Codable {
    var id: UUID = UUID()
    var startTime: Date?
    var frames: [RecordedFrame]

    init(frames: [RecordedFrame]) {
        self.frames = frames
        self.startTime = Date()
    }
}
