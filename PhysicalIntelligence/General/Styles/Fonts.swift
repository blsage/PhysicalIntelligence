//
//  Fonts.swift
//  Redpill
//
//  Created by Benjamin Sage on 6/9/24.
//

import Foundation

import SwiftUI

extension Font {
    static let redpill = Font.system(size: 24, weight: .medium)
    static let header = Font.system(size: 29, weight: .bold)
    static let button = Font.system(size: 18, weight: .semibold)
    static let smallButton = Font.system(size: 15, weight: .semibold)
    static let subtitle = Font.system(size: 12, weight: .medium)
    static let fakeTitle = Font.system(size: 20)
    static let subheader = Font.system(size: 16, weight: .medium)
}

extension String {
    static let inter = "Inter"
}
