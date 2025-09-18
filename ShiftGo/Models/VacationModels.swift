//
//  VacationModels.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/9/18.
//

import Foundation
import SwiftUI

// MARK: - Vacation Settings Model
struct VacationSettings: Equatable {
    var targetMonth: String = ""
    var targetYear: Int = Calendar.current.component(.year, from: Date())
    var maxDaysPerMonth: Int = 8
    var maxDaysPerWeek: Int = 2
    var limitType: VacationLimitType = .monthly
    var deadline: Date = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    var isPublished: Bool = false
    var publishedAt: Date?
    var instructions: String = ""
    var allowPartialDays: Bool = false

    var hasMonthlyLimit: Bool { maxDaysPerMonth > 0 }
    var hasWeeklyLimit: Bool { maxDaysPerWeek > 0 }

    var limitDescription: String {
        var parts: [String] = []
        if hasMonthlyLimit {
            parts.append(String(format: "monthly_limit_format".localized, maxDaysPerMonth))
        }
        if hasWeeklyLimit {
            parts.append(String(format: "weekly_limit_format".localized, maxDaysPerWeek))
        }
        return parts.isEmpty ? "no_limit".localized : parts.joined(separator: " • ")
    }

    var isExpired: Bool {
        return Date() > deadline
    }

    static func defaultSettings(for year: Int, month: Int) -> VacationSettings {
        let yearMonth = YearMonth(year: year, month: month)
        return VacationSettings(
            targetMonth: yearMonth.localizedMonthString,
            targetYear: year,
            maxDaysPerMonth: 8,
            maxDaysPerWeek: 0,
            limitType: .monthly,
            instructions: "default_vacation_instructions".localized
        )
    }
}

// MARK: - Employee Vacation Model
struct EmployeeVacation: Identifiable {
    let id = UUID()
    let employeeName: String
    let employeeId: String
    let dates: Set<String>
    let submitDate: Date
    let status: VacationRequestStatus
    let note: String
    let reviewNote: String?
    let reviewedBy: String?
    let reviewedAt: Date?

    enum VacationRequestStatus: String, CaseIterable {
        case pending = "pending"
        case approved = "approved"
        case rejected = "rejected"
        case cancelled = "cancelled"

        var displayText: String {
            switch self {
            case .pending: return "vacation_status_pending".localized
            case .approved: return "vacation_status_approved".localized
            case .rejected: return "vacation_status_rejected".localized
            case .cancelled: return "vacation_status_cancelled".localized
            }
        }

        var color: Color {
            switch self {
            case .pending: return .orange
            case .approved: return .green
            case .rejected: return .red
            case .cancelled: return .gray
            }
        }

        var icon: String {
            switch self {
            case .pending: return "clock.badge.questionmark"
            case .approved: return "checkmark.circle.fill"
            case .rejected: return "xmark.circle.fill"
            case .cancelled: return "minus.circle.fill"
            }
        }
    }

    init(employeeName: String, employeeId: String, dates: Set<String>,
         submitDate: Date, status: VacationRequestStatus, note: String = "",
         reviewNote: String? = nil, reviewedBy: String? = nil, reviewedAt: Date? = nil) {
        self.employeeName = employeeName
        self.employeeId = employeeId
        self.dates = dates
        self.submitDate = submitDate
        self.status = status
        self.note = note
        self.reviewNote = reviewNote
        self.reviewedBy = reviewedBy
        self.reviewedAt = reviewedAt
    }

    var daysCount: Int { dates.count }
    var canBeModified: Bool { status == .pending }
}

// MARK: - Vacation Validator
struct VacationValidator {
    let settings: VacationSettings

    func validate(selectedDates: Set<YearMonthDay>, targetYear: Int, targetMonth: Int) -> VacationValidationResult {
        if settings.isExpired {
            return .deadlineExpired
        }

        let monthlyDates = selectedDates.filter { $0.year == targetYear && $0.month == targetMonth }

        if settings.hasMonthlyLimit && monthlyDates.count > settings.maxDaysPerMonth {
            return .monthlyLimitExceeded(current: monthlyDates.count, limit: settings.maxDaysPerMonth)
        }

        if settings.hasWeeklyLimit {
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
        }

        return .valid
    }
}
