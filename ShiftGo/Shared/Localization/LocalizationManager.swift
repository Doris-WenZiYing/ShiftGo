//
//  LocalizationManager.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/9/18.
//

import Foundation
import SwiftUI

// MARK: - Localization Manager
class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()

    @Published var currentLanguage: SupportedLanguage = .system

    enum SupportedLanguage: String, CaseIterable {
        case system = "system"
        case english = "en"
        case chineseTraditional = "zh-Hant"

        var displayName: String {
            switch self {
            case .system: return "System Default"
            case .english: return "English"
            case .chineseTraditional: return "中文繁體"
            }
        }

        var localeIdentifier: String {
            switch self {
            case .system: return Locale.current.identifier
            case .english: return "en"
            case .chineseTraditional: return "zh-Hans"
            }
        }
    }

    private init() {
        // Load saved language preference
        if let savedLanguage = UserDefaults.standard.string(forKey: "selected_language"),
           let language = SupportedLanguage(rawValue: savedLanguage) {
            currentLanguage = language
        }
    }

    func setLanguage(_ language: SupportedLanguage) {
        currentLanguage = language
        UserDefaults.standard.set(language.rawValue, forKey: "selected_language")
        objectWillChange.send()
    }

    func localizedString(for key: String, comment: String = "") -> String {
        if currentLanguage == .system {
            return NSLocalizedString(key, comment: comment)
        }

        guard let bundle = Bundle.main.path(forResource: currentLanguage.localeIdentifier, ofType: "lproj"),
              let localizationBundle = Bundle(path: bundle) else {
            return NSLocalizedString(key, comment: comment)
        }

        return NSLocalizedString(key, bundle: localizationBundle, comment: comment)
    }
}

// MARK: - SwiftUI Localization Environment
struct LocalizationEnvironment: ViewModifier {
    @ObservedObject private var localizationManager = LocalizationManager.shared

    func body(content: Content) -> some View {
        content
            .environment(\.locale, Locale(identifier: localizationManager.currentLanguage.localeIdentifier))
    }
}

extension View {
    func withLocalization() -> some View {
        modifier(LocalizationEnvironment())
    }
}
