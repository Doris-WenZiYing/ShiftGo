//
//  PayrollModels.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/9/17.
//

import Foundation
import SwiftUI

// MARK: - Payroll Period
struct PayrollPeriod: Equatable {
    let startDate: Date
    let endDate: Date
    let year: Int
    let month: Int

    init(year: Int, month: Int) {
        let calendar = Calendar.current
        let startComponents = DateComponents(year: year, month: month, day: 1)
        self.startDate = calendar.date(from: startComponents)!
        self.endDate = calendar.date(byAdding: .month, value: 1, to: self.startDate)!.addingTimeInterval(-1)
        self.year = year
        self.month = month
    }

    static var currentMonth: PayrollPeriod {
        let now = Date()
        let year = Calendar.current.component(.year, from: now)
        let month = Calendar.current.component(.month, from: now)
        return PayrollPeriod(year: year, month: month)
    }

    var displayString: String {
        let yearMonth = YearMonth(year: year, month: month)
        return "\(year) \(yearMonth.localizedMonthString)"
    }
}

// MARK: - Payroll Report Model
struct PayrollReport {
    let period: PayrollPeriod
    let employeeId: String
    let employeeName: String
    let totalEarnings: Int
    let basePay: Int
    let overtimePay: Int
    let allowances: [PayrollComponent]
    let deductions: [PayrollComponent]
    let netPay: Int

    init(period: PayrollPeriod, employeeId: String, employeeName: String,
         totalEarnings: Int = 0, basePay: Int = 0, overtimePay: Int = 0,
         allowances: [PayrollComponent] = [], deductions: [PayrollComponent] = []) {
        self.period = period
        self.employeeId = employeeId
        self.employeeName = employeeName
        self.totalEarnings = totalEarnings
        self.basePay = basePay
        self.overtimePay = overtimePay
        self.allowances = allowances
        self.deductions = deductions
        self.netPay = totalEarnings - deductions.reduce(0) { $0 + $1.amount }
    }
}

// MARK: - Payroll Component
struct PayrollComponent: Identifiable {
    let id = UUID()
    let name: String
    let amount: Int
    let description: String
    let type: ComponentType
    let isDeduction: Bool

    enum ComponentType: String, CaseIterable {
        case basePay = "base_pay"
        case overtime = "overtime"
        case bonus = "bonus"
        case allowance = "allowance"
        case deduction = "deduction"
        case tax = "tax"

        var displayName: String {
            switch self {
            case .basePay: return "component_base_pay".localized
            case .overtime: return "component_overtime".localized
            case .bonus: return "component_bonus".localized
            case .allowance: return "component_allowance".localized
            case .deduction: return "component_deduction".localized
            case .tax: return "component_tax".localized
            }
        }
    }

    init(name: String, amount: Int, description: String = "",
         type: ComponentType, isDeduction: Bool = false) {
        self.name = name
        self.amount = amount
        self.description = description
        self.type = type
        self.isDeduction = isDeduction
    }
}

// MARK: - Time Record
struct TimeRecord: Identifiable {
    let id = UUID()
    let dateString: String
    let clockIn: String
    let clockOut: String?
    let totalHours: Int
    let status: AttendanceStatus
    let breakDuration: Int // in minutes
    let note: String

    init(dateString: String, clockIn: String, clockOut: String?, totalHours: Int,
         status: AttendanceStatus, breakDuration: Int = 60, note: String = "") {
        self.dateString = dateString
        self.clockIn = clockIn
        self.clockOut = clockOut
        self.totalHours = totalHours
        self.status = status
        self.breakDuration = breakDuration
        self.note = note
    }

    var workingHours: Double {
        return Double(totalHours) - (Double(breakDuration) / 60.0)
    }

    var isComplete: Bool {
        return clockOut != nil
    }
}

// MARK: - Income Data Point
struct IncomeDataPoint: Identifiable {
    let id = UUID()
    let label: String
    let amount: Int
    let date: Date?
    let category: IncomeCategory

    init(label: String, amount: Int, date: Date? = nil,
         category: IncomeCategory = .salary) {
        self.label = label
        self.amount = amount
        self.date = date
        self.category = category
    }
}
