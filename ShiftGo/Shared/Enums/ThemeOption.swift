//
//  ThemeOptions.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/8/26.
//

import Foundation

enum ThemeOption: String, CaseIterable {
    case automatic = "Automatic (iOS Settings)"
    case light = "Light Mode"
    case dark = "Dark Mode"

    var displayName: String {
        switch self {
        case .automatic: return "Automatic"
        case .light: return "Light Mode"
        case .dark: return "Dark Mode"
        }
    }

    var icon: String {
        switch self {
        case .automatic: return "gearshape.fill"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
}
