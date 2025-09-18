//
//  UIModels.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/9/3.
//

import Foundation
import SwiftUI

// MARK: - Toast Message
struct ToastMessage: Identifiable {
    let id = UUID()
    let type: ToastType
    let title: String?
    let message: String
    let duration: TimeInterval
    let action: ToastAction?

    init(type: ToastType, title: String? = nil, message: String,
         duration: TimeInterval = 3.0, action: ToastAction? = nil) {
        self.type = type
        self.title = title
        self.message = message
        self.duration = duration
        self.action = action
    }

    var displayTitle: String {
        return title ?? type.title
    }
}

struct ToastAction {
    let title: String
    let action: () -> Void
}

// MARK: - Alert Configuration
struct AlertConfiguration {
    let type: AlertType
    let title: String
    let message: String
    let primaryButton: AlertButton
    let secondaryButton: AlertButton?

    init(type: AlertType, title: String? = nil, message: String,
         primaryButton: AlertButton, secondaryButton: AlertButton? = nil) {
        self.type = type
        self.title = title ?? type.title
        self.message = message
        self.primaryButton = primaryButton
        self.secondaryButton = secondaryButton
    }
}

struct AlertButton {
    let title: String
    let role: ButtonRole?
    let action: (() -> Void)?

    enum ButtonRole {
        case cancel
        case destructive
    }

    init(title: String, role: ButtonRole? = nil, action: (() -> Void)? = nil) {
        self.title = title
        self.role = role
        self.action = action
    }

    static let cancel = AlertButton(title: "button_cancel".localized, role: .cancel)
    static let ok = AlertButton(title: "button_ok".localized)
    static let delete = AlertButton(title: "button_delete".localized, role: .destructive)
}
