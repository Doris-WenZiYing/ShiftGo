//
//  LocalModels.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/8/30.
//

import Foundation
import SwiftUI

// MARK: - 排休設定模型
struct VacationSettings: Equatable {
    var targetMonth: String = ""
    var targetYear: Int = Calendar.current.component(.year, from: Date())
    var maxDaysPerMonth: Int = 8  // 0 表示無限制
    var maxDaysPerWeek: Int = 2   // 0 表示無限制
    var limitType: VacationLimitType = .monthly
    var deadline: Date = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    var isPublished: Bool = false
    var publishedAt: Date?

    // 🔥 新增：檢查是否有月限制
    var hasMonthlyLimit: Bool {
        return maxDaysPerMonth > 0
    }

    // 🔥 新增：檢查是否有週限制
    var hasWeeklyLimit: Bool {
        return maxDaysPerWeek > 0
    }

    // 🔥 新增：獲取限制描述
    var limitDescription: String {
        var parts: [String] = []

        if hasMonthlyLimit {
            parts.append("月上限\(maxDaysPerMonth)天")
        }

        if hasWeeklyLimit {
            parts.append("週上限\(maxDaysPerWeek)天")
        }

        if parts.isEmpty {
            return "無限制"
        }

        return parts.joined(separator: "・")
    }

    // 🔥 新增：獲取主要限制類型
    var primaryLimitType: VacationLimitType {
        if hasMonthlyLimit && hasWeeklyLimit {
            return .monthly // 預設優先月限制
        } else if hasMonthlyLimit {
            return .monthly
        } else if hasWeeklyLimit {
            return .weekly
        } else {
            return .monthly // 預設
        }
    }
}

// MARK: - 員工排休模型
struct EmployeeVacation: Identifiable {
    let id = UUID()
    let employeeName: String
    let employeeId: String
    let dates: Set<String>
    let submitDate: Date
    let status: VacationRequestStatus
    let note: String

    enum VacationRequestStatus {
        case pending
        case approved
        case rejected

        var displayText: String {
            switch self {
            case .pending: return "待審核"
            case .approved: return "已核准"
            case .rejected: return "已拒絕"
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

// MARK: - 排休限制類型
enum VacationLimitType: String, CaseIterable {
    case weekly = "週排休"
    case monthly = "月排休"
    case flexible = "彈性排休"

    var description: String {
        switch self {
        case .weekly:
            return "以週為單位限制排休天數"
        case .monthly:
            return "以月為單位限制排休天數"
        case .flexible:
            return "可同時設定月限制和週限制"
        }
    }

    var icon: String {
        switch self {
        case .weekly:
            return "calendar.day.timeline.left"
        case .monthly:
            return "calendar"
        case .flexible:
            return "slider.horizontal.3"
        }
    }

    var color: Color {
        switch self {
        case .weekly:
            return .purple
        case .monthly:
            return .orange
        case .flexible:
            return .blue
        }
    }
}

struct VacationValidator {
    let settings: VacationSettings

    init(settings: VacationSettings) {
        self.settings = settings
    }

    // 檢查選擇的日期是否超過月限制
    func validateMonthlyLimit(selectedDates: Set<YearMonthDay>, targetYear: Int, targetMonth: Int) -> VacationValidationResult {
        guard settings.hasMonthlyLimit else {
            return .valid
        }

        let monthlyDates = selectedDates.filter { $0.year == targetYear && $0.month == targetMonth }

        if monthlyDates.count > settings.maxDaysPerMonth {
            return .monthlyLimitExceeded(current: monthlyDates.count, limit: settings.maxDaysPerMonth)
        }

        return .valid
    }

    // 檢查選擇的日期是否超過週限制
    func validateWeeklyLimit(selectedDates: Set<YearMonthDay>, targetYear: Int, targetMonth: Int) -> VacationValidationResult {
        guard settings.hasWeeklyLimit else {
            return .valid
        }

        let monthlyDates = selectedDates.filter { $0.year == targetYear && $0.month == targetMonth }

        // 按週分組檢查
        let calendar = Calendar.current
        var weekGroups: [Int: Int] = [:] // 週數: 天數

        for date in monthlyDates {
            if let actualDate = calendar.date(from: DateComponents(year: date.year, month: date.month, day: date.day)) {
                let weekOfYear = calendar.component(.weekOfYear, from: actualDate)
                weekGroups[weekOfYear, default: 0] += 1
            }
        }

        // 檢查是否有任何一週超過限制
        for (week, count) in weekGroups {
            if count > settings.maxDaysPerWeek {
                return .weeklyLimitExceeded(week: week, current: count, limit: settings.maxDaysPerWeek)
            }
        }

        return .valid
    }

    // 綜合驗證
    func validate(selectedDates: Set<YearMonthDay>, targetYear: Int, targetMonth: Int) -> VacationValidationResult {
        // 先檢查月限制
        let monthlyResult = validateMonthlyLimit(selectedDates: selectedDates, targetYear: targetYear, targetMonth: targetMonth)
        if case .monthlyLimitExceeded = monthlyResult {
            return monthlyResult
        }

        // 再檢查週限制
        let weeklyResult = validateWeeklyLimit(selectedDates: selectedDates, targetYear: targetYear, targetMonth: targetMonth)
        if case .weeklyLimitExceeded = weeklyResult {
            return weeklyResult
        }

        return .valid
    }

    // 檢查是否可以選擇新的日期
    func canSelectDate(_ newDate: YearMonthDay, currentSelection: Set<YearMonthDay>) -> Bool {
        // 如果已經選擇了這個日期，可以取消選擇
        if currentSelection.contains(newDate) {
            return true
        }

        // 創建新的選擇集合
        var newSelection = currentSelection
        newSelection.insert(newDate)

        // 驗證新的選擇集合
        let result = validate(selectedDates: newSelection, targetYear: newDate.year, targetMonth: newDate.month)
        return result == .valid
    }
}

enum VacationValidationResult: Equatable {
    case valid
    case monthlyLimitExceeded(current: Int, limit: Int)
    case weeklyLimitExceeded(week: Int, current: Int, limit: Int)

    var isValid: Bool {
        return self == .valid
    }

    var errorMessage: String? {
        switch self {
        case .valid:
            return nil
        case .monthlyLimitExceeded(let current, let limit):
            return "超過月排休上限！目前選擇 \(current) 天，上限為 \(limit) 天"
        case .weeklyLimitExceeded(let week, let current, let limit):
            return "第 \(week) 週超過排休上限！目前選擇 \(current) 天，上限為 \(limit) 天"
        }
    }
}

struct VacationStatsHelper {
    static func getStats(
        selectedDates: Set<YearMonthDay>,
        settings: VacationSettings,
        targetYear: Int,
        targetMonth: Int
    ) -> VacationStats {
        let monthlyDates = selectedDates.filter { $0.year == targetYear && $0.month == targetMonth }

        // 計算週統計
        var weekStats: [Int: Int] = [:]
        let calendar = Calendar.current

        for date in monthlyDates {
            if let actualDate = calendar.date(from: DateComponents(year: date.year, month: date.month, day: date.day)) {
                let weekOfYear = calendar.component(.weekOfYear, from: actualDate)
                weekStats[weekOfYear, default: 0] += 1
            }
        }

        let maxWeeklyUsed = weekStats.values.max() ?? 0

        return VacationStats(
            selectedDays: monthlyDates.count,
            monthlyLimit: settings.hasMonthlyLimit ? settings.maxDaysPerMonth : nil,
            weeklyLimit: settings.hasWeeklyLimit ? settings.maxDaysPerWeek : nil,
            maxWeeklyUsed: maxWeeklyUsed,
            hasMonthlyLimit: settings.hasMonthlyLimit,
            hasWeeklyLimit: settings.hasWeeklyLimit
        )
    }
}

// MARK: - 排休統計模型
struct VacationStats {
    let selectedDays: Int
    let monthlyLimit: Int?
    let weeklyLimit: Int?
    let maxWeeklyUsed: Int
    let hasMonthlyLimit: Bool
    let hasWeeklyLimit: Bool

    var monthlyUsagePercentage: Double? {
        guard let limit = monthlyLimit, limit > 0 else { return nil }
        return Double(selectedDays) / Double(limit)
    }

    var weeklyUsagePercentage: Double? {
        guard let limit = weeklyLimit, limit > 0 else { return nil }
        return Double(maxWeeklyUsed) / Double(limit)
    }

    var isNearMonthlyLimit: Bool {
        guard let percentage = monthlyUsagePercentage else { return false }
        return percentage >= 0.8
    }

    var isNearWeeklyLimit: Bool {
        guard let percentage = weeklyUsagePercentage else { return false }
        return percentage >= 0.8
    }
}

// MARK: - 員工排休狀態
enum EmployeeVacationStatus {
    case notSubmitted
    case pending
    case approved
    case rejected
    case expired

    var displayText: String {
        switch self {
        case .notSubmitted: return "尚未申請"
        case .pending: return "審核中"
        case .approved: return "已核准"
        case .rejected: return "已拒絕"
        case .expired: return "已過期"
        }
    }

    var color: Color {
        switch self {
        case .notSubmitted: return .gray
        case .pending: return .orange
        case .approved: return .green
        case .rejected: return .red
        case .expired: return .gray
        }
    }

    var icon: String {
        switch self {
        case .notSubmitted: return "calendar.badge.plus"
        case .pending: return "clock.badge.questionmark"
        case .approved: return "checkmark.circle.fill"
        case .rejected: return "xmark.circle.fill"
        case .expired: return "calendar.badge.exclamationmark"
        }
    }
}

// MARK: - 快速選擇模型
struct QuickSelectOption {
    let title: String
    let dates: Set<YearMonthDay>
    let description: String

    static func weekendOptions(for year: Int, month: Int) -> [QuickSelectOption] {
        var options: [QuickSelectOption] = []

        // 找出該月所有的週末
        let calendar = Calendar.current
        let date = calendar.date(from: DateComponents(year: year, month: month, day: 1))!
        let range = calendar.range(of: .day, in: .month, for: date)!

        var weekends: [YearMonthDay] = []

        for day in 1...range.count {
            let currentDate = calendar.date(from: DateComponents(year: year, month: month, day: day))!
            let weekday = calendar.component(.weekday, from: currentDate)

            if weekday == 1 || weekday == 7 { // Sunday or Saturday
                weekends.append(YearMonthDay(year: year, month: month, day: day))
            }
        }

        if weekends.count >= 2 {
            options.append(QuickSelectOption(
                title: "所有週末",
                dates: Set(weekends),
                description: "選擇本月所有週末 (\(weekends.count)天)"
            ))
        }

        return options
    }
}

// MARK: - 通知設定模型
struct NotificationSettings: Codable {
    var enablePushNotifications: Bool = true
    var enableEmailNotifications: Bool = true
    var notifyOnRequestSubmitted: Bool = true
    var notifyOnRequestReviewed: Bool = true
    var notifyOnDeadlineApproaching: Bool = true
    var notifyOnSchedulePublished: Bool = true
    var reminderDaysBefore: Int = 1
    var quietHoursStart: String = "22:00"
    var quietHoursEnd: String = "08:00"
}

// MARK: - 公司設定模型
struct CompanySettings {
    let id: String
    let name: String
    let timezone: String
    let workDaysPerWeek: Int
    let standardWorkHours: Int
    let overtimePolicy: String
    let vacationPolicy: String
}

// MARK: - 員工資訊模型
struct EmployeeInfo: Identifiable {
    let id = UUID()
    let userId: String
    let employeeId: String
    let name: String
    let email: String
    let department: String?
    let position: String?
    let hireDate: Date
    let totalVacationDays: Int
    let usedVacationDays: Int
    let isActive: Bool

    var remainingVacationDays: Int {
        return max(0, totalVacationDays - usedVacationDays)
    }
}

// MARK: - VacationSettings
extension VacationSettings {
    static func defaultSettings(for year: Int, month: Int) -> VacationSettings {
        let months = [
            1: "1月", 2: "2月", 3: "3月", 4: "4月",
            5: "5月", 6: "6月", 7: "7月", 8: "8月",
            9: "9月", 10: "10月", 11: "11月", 12: "12月"
        ]

        return VacationSettings(
            targetMonth: months[month] ?? "",
            targetYear: year,
            maxDaysPerMonth: 8, // 預設有月限制
            maxDaysPerWeek: 0,  // 預設無週限制
            limitType: .monthly,
            deadline: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
            isPublished: false,
            publishedAt: nil
        )
    }

    // 🔥 新增：只有月限制的設定
    static func monthlyOnlySettings(for year: Int, month: Int, maxDays: Int = 8) -> VacationSettings {
        let months = [
            1: "1月", 2: "2月", 3: "3月", 4: "4月",
            5: "5月", 6: "6月", 7: "7月", 8: "8月",
            9: "9月", 10: "10月", 11: "11月", 12: "12月"
        ]

        return VacationSettings(
            targetMonth: months[month] ?? "",
            targetYear: year,
            maxDaysPerMonth: maxDays,
            maxDaysPerWeek: 0, // 無週限制
            limitType: .monthly,
            deadline: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
            isPublished: false,
            publishedAt: nil
        )
    }

    // 🔥 新增：只有週限制的設定
    static func weeklyOnlySettings(for year: Int, month: Int, maxDays: Int = 2) -> VacationSettings {
        let months = [
            1: "1月", 2: "2月", 3: "3月", 4: "4月",
            5: "5月", 6: "6月", 7: "7月", 8: "8月",
            9: "9月", 10: "10月", 11: "11月", 12: "12月"
        ]

        return VacationSettings(
            targetMonth: months[month] ?? "",
            targetYear: year,
            maxDaysPerMonth: 0, // 無月限制
            maxDaysPerWeek: maxDays,
            limitType: .weekly,
            deadline: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
            isPublished: false,
            publishedAt: nil
        )
    }

    // 🔥 新增：彈性限制的設定
    static func flexibleSettings(for year: Int, month: Int, monthlyMax: Int = 8, weeklyMax: Int = 2) -> VacationSettings {
        let months = [
            1: "1月", 2: "2月", 3: "3月", 4: "4月",
            5: "5月", 6: "6月", 7: "7月", 8: "8月",
            9: "9月", 10: "10月", 11: "11月", 12: "12月"
        ]

        return VacationSettings(
            targetMonth: months[month] ?? "",
            targetYear: year,
            maxDaysPerMonth: monthlyMax,
            maxDaysPerWeek: weeklyMax,
            limitType: .flexible,
            deadline: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
            isPublished: false,
            publishedAt: nil
        )
    }
}
