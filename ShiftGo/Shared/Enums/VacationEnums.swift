//
//  VacationEnums.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/9/18.
//

import Foundation
import SwiftUI

// MARK: - Vacation Limit Type
enum VacationLimitType: String, CaseIterable {
    case weekly = "weekly"
    case monthly = "monthly"
    case flexible = "flexible"

    var displayName: String {
        switch self {
        case .weekly: return "vacation_limit_weekly".localized
        case .monthly: return "vacation_limit_monthly".localized
        case .flexible: return "vacation_limit_flexible".localized
        }
    }

    var description: String {
        switch self {
        case .weekly: return "vacation_limit_weekly_description".localized
        case .monthly: return "vacation_limit_monthly_description".localized
        case .flexible: return "vacation_limit_flexible_description".localized
        }
    }

    var icon: String {
        switch self {
        case .weekly: return "calendar.day.timeline.left"
        case .monthly: return "calendar"
        case .flexible: return "slider.horizontal.3"
        }
    }

    var color: Color {
        switch self {
        case .weekly: return .purple
        case .monthly: return .orange
        case .flexible: return .blue
        }
    }
}

// MARK: - Vacation Validation Result
enum VacationValidationResult: Equatable {
    case valid
    case monthlyLimitExceeded(current: Int, limit: Int)
    case weeklyLimitExceeded(week: Int, current: Int, limit: Int)
    case deadlineExpired
    case invalidDateRange
    case noSelectionMade

    var isValid: Bool { self == .valid }

    var errorMessage: String? {
        switch self {
        case .valid:
            return nil
        case .monthlyLimitExceeded(let current, let limit):
            return String(format: "error_monthly_limit_exceeded".localized, current, limit)
        case .weeklyLimitExceeded(let week, let current, let limit):
            return String(format: "error_weekly_limit_exceeded".localized, week, current, limit)
        case .deadlineExpired:
            return "error_deadline_expired".localized
        case .invalidDateRange:
            return "error_invalid_date_range".localized
        case .noSelectionMade:
            return "error_no_selection_made".localized
        }
    }

    var warningLevel: AlertType {
        switch self {
        case .valid: return .success
        case .monthlyLimitExceeded, .weeklyLimitExceeded, .noSelectionMade: return .warning
        case .deadlineExpired, .invalidDateRange: return .error
        }
    }
}
