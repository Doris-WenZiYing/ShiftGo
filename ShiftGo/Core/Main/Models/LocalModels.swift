//
//  LocalModels.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/8/30.
//

import Foundation
import SwiftUI

// MARK: - 排休設定模型
struct VacationSettings {
    var targetMonth: String = ""
    var targetYear: Int = Calendar.current.component(.year, from: Date())
    var maxDaysPerMonth: Int = 8
    var maxDaysPerWeek: Int = 2
    var limitType: VacationLimitType = .monthly
    var deadline: Date = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    var isPublished: Bool = false
    var publishedAt: Date?
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

    var description: String {
        switch self {
        case .weekly:
            return "以週為單位限制排休天數"
        case .monthly:
            return "以月為單位限制排休天數"
        }
    }

    var icon: String {
        switch self {
        case .weekly: return "calendar.day.timeline.left"
        case .monthly: return "calendar"
        }
    }
}

// MARK: - 排休統計模型
struct VacationStats {
    let totalEmployees: Int
    let totalDays: Int
    let pendingRequests: Int
    let approvedRequests: Int
    let rejectedRequests: Int

    var totalRequests: Int {
        return pendingRequests + approvedRequests + rejectedRequests
    }

    var approvalRate: Double {
        guard totalRequests > 0 else { return 0 }
        return Double(approvedRequests) / Double(totalRequests)
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
        var date = calendar.date(from: DateComponents(year: year, month: month, day: 1))!
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
struct NotificationSettings {
    var enablePushNotifications: Bool = true
    var enableEmailNotifications: Bool = true
    var notifyOnRequestSubmitted: Bool = true
    var notifyOnRequestReviewed: Bool = true
    var notifyOnDeadlineApproaching: Bool = true
    var reminderDaysBefore: Int = 3
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

// MARK: - 便利初始化器
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
            maxDaysPerMonth: 8,
            maxDaysPerWeek: 2,
            limitType: .monthly,
            deadline: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
            isPublished: false,
            publishedAt: nil
        )
    }
}

extension EmployeeVacation {
    static func mockData(for year: Int, month: Int) -> [EmployeeVacation] {
        return [
            EmployeeVacation(
                employeeName: "王小明",
                employeeId: "E001",
                dates: Set([
                    String(format: "%04d-%02d-15", year, month),
                    String(format: "%04d-%02d-16", year, month)
                ]),
                submitDate: Date(),
                status: .pending,
                note: "家庭旅遊"
            ),
            EmployeeVacation(
                employeeName: "李美麗",
                employeeId: "E002",
                dates: Set([
                    String(format: "%04d-%02d-20", year, month),
                    String(format: "%04d-%02d-21", year, month),
                    String(format: "%04d-%02d-22", year, month)
                ]),
                submitDate: Date(),
                status: .approved,
                note: "出國度假"
            ),
            EmployeeVacation(
                employeeName: "陳大華",
                employeeId: "E003",
                dates: Set([String(format: "%04d-%02d-10", year, month)]),
                submitDate: Date(),
                status: .pending,
                note: "醫療預約"
            ),
            EmployeeVacation(
                employeeName: "張小花",
                employeeId: "E004",
                dates: Set([
                    String(format: "%04d-%02d-25", year, month),
                    String(format: "%04d-%02d-26", year, month)
                ]),
                submitDate: Date(),
                status: .approved,
                note: "家人生日"
            )
        ]
    }
}
