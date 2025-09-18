//
//  LocalModels.swift
//  ShiftGo
//
//  Refactored: Stage 2 - Internationalized Local Models
//

import Foundation
import SwiftUI

// MARK: - Vacation Settings
struct VacationSettings: Equatable {
    var targetMonth: String = ""
    var targetYear: Int = Calendar.current.component(.year, from: Date())
    var maxDaysPerMonth: Int = 8
    var maxDaysPerWeek: Int = 2
    var limitType: VacationLimitType = .monthly
    var deadline: Date = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    var isPublished: Bool = false
    var publishedAt: Date?

    var hasMonthlyLimit: Bool { maxDaysPerMonth > 0 }
    var hasWeeklyLimit: Bool { maxDaysPerWeek > 0 }

    var limitDescription: String {
        var parts: [String] = []
        if hasMonthlyLimit {
            parts.append(String(format: "%@ %d %@", "vacation_limit_monthly".localized, maxDaysPerMonth, "days"))
        }
        if hasWeeklyLimit {
            parts.append(String(format: "%@ %d %@", "vacation_limit_weekly".localized, maxDaysPerWeek, "days"))
        }
        return parts.isEmpty ? "no_limit".localized : parts.joined(separator: " • ")
    }

    static func defaultSettings(for year: Int, month: Int) -> VacationSettings {
        let monthNames = [
            1: "month_january".localized, 2: "month_february".localized, 3: "month_march".localized,
            4: "month_april".localized, 5: "month_may".localized, 6: "month_june".localized,
            7: "month_july".localized, 8: "month_august".localized, 9: "month_september".localized,
            10: "month_october".localized, 11: "month_november".localized, 12: "month_december".localized
        ]

        return VacationSettings(
            targetMonth: monthNames[month] ?? "",
            targetYear: year,
            maxDaysPerMonth: 8,
            maxDaysPerWeek: 0,
            limitType: .monthly
        )
    }
}

// MARK: - Employee Vacation
struct EmployeeVacation: Identifiable {
    let id = UUID()
    let employeeName: String
    let employeeId: String
    let dates: Set<String>
    let submitDate: Date
    let status: VacationRequestStatus
    let note: String

    enum VacationRequestStatus {
        case pending, approved, rejected

        var displayText: String {
            switch self {
            case .pending: return "vacation_status_pending".localized
            case .approved: return "vacation_status_approved".localized
            case .rejected: return "vacation_status_rejected".localized
            }
        }

        var color: Color {
            switch self {
            case .pending: return .orange
            case .approved: return .green
            case .rejected: return .red
            }
        }
    }
}

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
        case .weekly: return "limit_weekly_description".localized
        case .monthly: return "limit_monthly_description".localized
        case .flexible: return "limit_flexible_description".localized
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

// MARK: - Vacation Validator
struct VacationValidator {
    let settings: VacationSettings

    func validateMonthlyLimit(selectedDates: Set<YearMonthDay>, targetYear: Int, targetMonth: Int) -> VacationValidationResult {
        guard settings.hasMonthlyLimit else { return .valid }

        let monthlyDates = selectedDates.filter { $0.year == targetYear && $0.month == targetMonth }

        if monthlyDates.count > settings.maxDaysPerMonth {
            return .monthlyLimitExceeded(current: monthlyDates.count, limit: settings.maxDaysPerMonth)
        }

        return .valid
    }

    func validateWeeklyLimit(selectedDates: Set<YearMonthDay>, targetYear: Int, targetMonth: Int) -> VacationValidationResult {
        guard settings.hasWeeklyLimit else { return .valid }

        let monthlyDates = selectedDates.filter { $0.year == targetYear && $0.month == targetMonth }
        let calendar = Calendar.current
        var weekGroups: [Int: Int] = [:]

        for date in monthlyDates {
            if let actualDate = calendar.date(from: DateComponents(year: date.year, month: date.month, day: date.day)) {
                let weekOfYear = calendar.component(.weekOfYear, from: actualDate)
                weekGroups[weekOfYear, default: 0] += 1
            }
        }

        for (week, count) in weekGroups {
            if count > settings.maxDaysPerWeek {
                return .weeklyLimitExceeded(week: week, current: count, limit: settings.maxDaysPerWeek)
            }
        }

        return .valid
    }

    func validate(selectedDates: Set<YearMonthDay>, targetYear: Int, targetMonth: Int) -> VacationValidationResult {
        let monthlyResult = validateMonthlyLimit(selectedDates: selectedDates, targetYear: targetYear, targetMonth: targetMonth)
        if case .monthlyLimitExceeded = monthlyResult { return monthlyResult }

        let weeklyResult = validateWeeklyLimit(selectedDates: selectedDates, targetYear: targetYear, targetMonth: targetMonth)
        if case .weeklyLimitExceeded = weeklyResult { return weeklyResult }

        return .valid
    }

    func canSelectDate(_ newDate: YearMonthDay, currentSelection: Set<YearMonthDay>) -> Bool {
        if currentSelection.contains(newDate) { return true }

        var newSelection = currentSelection
        newSelection.insert(newDate)

        let result = validate(selectedDates: newSelection, targetYear: newDate.year, targetMonth: newDate.month)
        return result == .valid
    }
}

// MARK: - Vacation Validation Result
enum VacationValidationResult: Equatable {
    case valid
    case monthlyLimitExceeded(current: Int, limit: Int)
    case weeklyLimitExceeded(week: Int, current: Int, limit: Int)

    var isValid: Bool { self == .valid }

    var errorMessage: String? {
        switch self {
        case .valid: return nil
        case .monthlyLimitExceeded(let current, let limit):
            return String(format: "validation_monthly_limit_exceeded".localized, current, limit)
        case .weeklyLimitExceeded(let week, let current, let limit):
            return String(format: "validation_weekly_limit_exceeded".localized, week, current, limit)
        }
    }
}

// MARK: - Additional supporting models with localization...
// (Continue with other models following the same internationalization pattern)
