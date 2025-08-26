//
//  ThemeManager.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/8/26.
//

import SwiftUI
import Combine

class ThemeManager: ObservableObject {
    @AppStorage("selectedTheme") var selectedTheme: String = ThemeOption.automatic.rawValue {
        didSet {
            objectWillChange.send()
        }
    }

    var currentTheme: ThemeOption {
        ThemeOption(rawValue: selectedTheme) ?? .automatic
    }

    var preferredColorScheme: ColorScheme? {
        switch currentTheme {
        case .automatic: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}
