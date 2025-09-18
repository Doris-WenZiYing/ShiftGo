//
//  UIEnums.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/9/18.
//

import Foundation
import SwiftUI

// MARK: - Toast Type
enum ToastType {
    case success
    case error
    case info
    case warning

    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .info: return "info.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        }
    }

    var color: Color {
        switch self {
        case .success: return .green
        case .error: return .red
        case .info: return .blue
        case .warning: return .orange
        }
    }

    var backgroundColor: Color {
        switch self {
        case .success: return Color.green.opacity(0.1)
        case .error: return Color.red.opacity(0.1)
        case .info: return Color.blue.opacity(0.1)
        case .warning: return Color.orange.opacity(0.1)
        }
    }

    var title: String {
        switch self {
        case .success: return "toast_success".localized
        case .error: return "toast_error".localized
        case .info: return "toast_info".localized
        case .warning: return "toast_warning".localized
        }
    }
}

// MARK: - Theme Option
enum ThemeOption: String, CaseIterable {
    case automatic = "automatic"
    case light = "light"
    case dark = "dark"

    var displayName: String {
        switch self {
        case .automatic: return "theme_automatic".localized
        case .light: return "theme_light".localized
        case .dark: return "theme_dark".localized
        }
    }

    var icon: String {
        switch self {
        case .automatic: return "gearshape.fill"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }

    var description: String {
        switch self {
        case .automatic: return "theme_automatic_description".localized
        case .light: return "theme_light_description".localized
        case .dark: return "theme_dark_description".localized
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .automatic: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

// MARK: - Tab Definitions
enum EmployeeTab: String, CaseIterable {
    case calendar = "calendar"
    case reports = "reports"
    case timeTracker = "timetracker"
    case more = "more"

    var icon: String {
        switch self {
        case .calendar: return "calendar"
        case .reports: return "chart.bar"
        case .timeTracker: return "clock.fill"
        case .more: return "line.3.horizontal"
        }
    }

    var label: String {
        switch self {
        case .calendar: return "tab_calendar".localized
        case .reports: return "tab_reports".localized
        case .timeTracker: return "tab_time_tracker".localized
        case .more: return "tab_more".localized
        }
    }

    var badgeColor: Color {
        switch self {
        case .calendar: return .blue
        case .reports: return .green
        case .timeTracker: return .orange
        case .more: return .purple
        }
    }
}

enum BossTab: String, CaseIterable {
    case dashboard = "dashboard"
    case employees = "employees"
    case schedules = "schedules"
    case analytics = "analytics"
    case more = "more"

    var icon: String {
        switch self {
        case .dashboard: return "house.fill"
        case .employees: return "person.2.fill"
        case .schedules: return "calendar.badge.clock"
        case .analytics: return "chart.line.uptrend.xyaxis"
        case .more: return "line.3.horizontal"
        }
    }

    var label: String {
        switch self {
        case .dashboard: return "tab_dashboard".localized
        case .employees: return "tab_employees".localized
        case .schedules: return "tab_schedules".localized
        case .analytics: return "tab_analytics".localized
        case .more: return "tab_more".localized
        }
    }

    var badgeColor: Color {
        switch self {
        case .dashboard: return .blue
        case .employees: return .green
        case .schedules: return .orange
        case .analytics: return .purple
        case .more: return .gray
        }
    }
}

// MARK: - Animation Type
enum AnimationType {
    case fadeIn
    case slideUp
    case slideDown
    case scale
    case bounce
    case spring
    case elastic

    var animation: Animation {
        switch self {
        case .fadeIn:
            return .easeInOut(duration: 0.3)
        case .slideUp:
            return .easeOut(duration: 0.4)
        case .slideDown:
            return .easeIn(duration: 0.4)
        case .scale:
            return .spring(response: 0.5, dampingFraction: 0.8)
        case .bounce:
            return .interpolatingSpring(stiffness: 300, damping: 15)
        case .spring:
            return .spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.3)
        case .elastic:
            return .interpolatingSpring(mass: 1, stiffness: 100, damping: 10, initialVelocity: 0)
        }
    }

    var duration: Double {
        switch self {
        case .fadeIn: return 0.3
        case .slideUp, .slideDown: return 0.4
        case .scale: return 0.5
        case .bounce: return 0.6
        case .spring: return 0.6
        case .elastic: return 0.8
        }
    }
}

// MARK: - Loading State
enum LoadingState: Equatable {
    case idle
    case loading
    case success
    case error(String)
    case refreshing

    var isLoading: Bool {
        switch self {
        case .loading, .refreshing: return true
        case .idle, .success, .error: return false
        }
    }

    var errorMessage: String? {
        if case .error(let message) = self { return message }
        return nil
    }

    var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }

    var isError: Bool {
        if case .error = self { return true }
        return false
    }

    var statusDescription: String {
        switch self {
        case .idle: return "status_idle".localized
        case .loading: return "status_loading".localized
        case .refreshing: return "status_refreshing".localized
        case .success: return "status_success".localized
        case .error(let message): return message
        }
    }

    static func == (lhs: LoadingState, rhs: LoadingState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading), (.success, .success), (.refreshing, .refreshing):
            return true
        case (.error(let lhsMessage), .error(let rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}

// MARK: - Alert Type
enum AlertType {
    case info
    case success
    case warning
    case error
    case confirmation
    case destructive

    var color: Color {
        switch self {
        case .info: return .blue
        case .success: return .green
        case .warning: return .orange
        case .error: return .red
        case .confirmation: return .purple
        case .destructive: return .red
        }
    }

    var icon: String {
        switch self {
        case .info: return "info.circle.fill"
        case .success: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .error: return "xmark.circle.fill"
        case .confirmation: return "questionmark.circle.fill"
        case .destructive: return "trash.fill"
        }
    }

    var title: String {
        switch self {
        case .info: return "alert_info".localized
        case .success: return "alert_success".localized
        case .warning: return "alert_warning".localized
        case .error: return "alert_error".localized
        case .confirmation: return "alert_confirmation".localized
        case .destructive: return "alert_destructive".localized
        }
    }
}

// MARK: - Validation State
enum ValidationState: Equatable {
    case valid
    case invalid(String)
    case pending
    case warning(String)

    var isValid: Bool {
        if case .valid = self { return true }
        return false
    }

    var errorMessage: String? {
        switch self {
        case .invalid(let message): return message
        case .warning(let message): return message
        case .valid, .pending: return nil
        }
    }

    var isPending: Bool {
        if case .pending = self { return true }
        return false
    }

    var isWarning: Bool {
        if case .warning = self { return true }
        return false
    }

    var color: Color {
        switch self {
        case .valid: return .green
        case .invalid: return .red
        case .pending: return .orange
        case .warning: return .yellow
        }
    }

    var icon: String {
        switch self {
        case .valid: return "checkmark.circle.fill"
        case .invalid: return "xmark.circle.fill"
        case .pending: return "clock.fill"
        case .warning: return "exclamationmark.triangle.fill"
        }
    }

    static func == (lhs: ValidationState, rhs: ValidationState) -> Bool {
        switch (lhs, rhs) {
        case (.valid, .valid), (.pending, .pending):
            return true
        case (.invalid(let lhsMessage), .invalid(let rhsMessage)),
             (.warning(let lhsMessage), .warning(let rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}

// MARK: - Button Variant
enum ButtonVariant {
    case primary
    case secondary
    case outline
    case ghost
    case destructive
    case link

    func backgroundColor(colorScheme: ColorScheme) -> Color {
        switch self {
        case .primary: return AppColors.Theme.primary
        case .secondary: return AppColors.Background.secondary(colorScheme)
        case .outline: return Color.clear
        case .ghost: return Color.clear
        case .destructive: return .red
        case .link: return Color.clear
        }
    }

    func foregroundColor(colorScheme: ColorScheme) -> Color {
        switch self {
        case .primary: return .white
        case .secondary: return AppColors.Text.header(colorScheme)
        case .outline: return AppColors.Theme.primary
        case .ghost: return AppColors.Text.header(colorScheme)
        case .destructive: return .white
        case .link: return AppColors.Theme.primary
        }
    }

    func borderColor(colorScheme: ColorScheme) -> Color {
        switch self {
        case .primary: return Color.clear
        case .secondary: return Color.clear
        case .outline: return AppColors.Theme.primary
        case .ghost: return Color.clear
        case .destructive: return Color.clear
        case .link: return Color.clear
        }
    }
}

// MARK: - Card Style
enum CardStyle {
    case elevated
    case outlined
    case filled
    case plain
    case glassmorphism

    func backgroundColor(colorScheme: ColorScheme) -> Color {
        switch self {
        case .elevated: return AppColors.Background.secondary(colorScheme)
        case .outlined: return AppColors.Background.primary(colorScheme)
        case .filled: return AppColors.Background.secondary(colorScheme)
        case .plain: return Color.clear
        case .glassmorphism: return AppColors.Background.secondary(colorScheme).opacity(0.8)
        }
    }

    var shadowRadius: CGFloat {
        switch self {
        case .elevated: return 4
        case .outlined: return 0
        case .filled: return 0
        case .plain: return 0
        case .glassmorphism: return 8
        }
    }

    func borderColor(colorScheme: ColorScheme) -> Color {
        switch self {
        case .elevated: return Color.clear
        case .outlined: return AppColors.Text.header(colorScheme).opacity(0.2)
        case .filled: return Color.clear
        case .plain: return Color.clear
        case .glassmorphism: return .white.opacity(0.2)
        }
    }
}

// MARK: - Modal Presentation Style
enum ModalPresentationStyle {
    case sheet
    case fullScreen
    case popover
    case custom(CGFloat) // fraction
    case large
    case medium

    var detents: Set<PresentationDetent> {
        switch self {
        case .sheet: return [.medium, .large]
        case .fullScreen: return [.large]
        case .popover: return [.medium]
        case .custom(let fraction): return [.fraction(fraction)]
        case .large: return [.large]
        case .medium: return [.medium]
        }
    }

    var dragIndicatorVisibility: Visibility {
        switch self {
        case .sheet, .medium: return .visible
        case .fullScreen, .popover, .custom, .large: return .hidden
        }
    }
}

// MARK: - Responsive Design Breakpoint
enum BreakPoint {
    case compact  // iPhone
    case regular  // iPad
    case large    // Large screens

    static func current(for sizeClass: UserInterfaceSizeClass?) -> BreakPoint {
        guard let sizeClass = sizeClass else { return .compact }
        switch sizeClass {
        case .compact: return .compact
        case .regular: return .regular
        @unknown default: return .compact
        }
    }

    var columns: Int {
        switch self {
        case .compact: return 1
        case .regular: return 2
        case .large: return 3
        }
    }

    var padding: CGFloat {
        switch self {
        case .compact: return 16
        case .regular: return 24
        case .large: return 32
        }
    }
}
