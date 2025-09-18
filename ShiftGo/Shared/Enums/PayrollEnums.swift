//
//  PayrollEnums.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/9/18.
//

import Foundation
import SwiftUI

// MARK: - Attendance Status
enum AttendanceStatus: String, CaseIterable {
    case normal = "normal"
    case late = "late"
    case overtime = "overtime"
    case leave = "leave"
    case absent = "absent"
    case earlyLeave = "early_leave"
    case holiday = "holiday"

    var displayText: String {
        switch self {
        case .normal: return "attendance_status_normal".localized
        case .late: return "attendance_status_late".localized
        case .overtime: return "attendance_status_overtime".localized
        case .leave: return "attendance_status_leave".localized
        case .absent: return "attendance_status_absent".localized
        case .earlyLeave: return "attendance_status_early_leave".localized
        case .holiday: return "attendance_status_holiday".localized
        }
    }

    var color: Color {
        switch self {
        case .normal: return .green
        case .late: return .orange
        case .overtime: return .blue
        case .leave: return .gray
        case .absent: return .red
        case .earlyLeave: return .yellow
        case .holiday: return .purple
        }
    }

    var icon: String {
        switch self {
        case .normal: return "checkmark.circle.fill"
        case .late: return "clock.fill"
        case .overtime: return "moon.stars.fill"
        case .leave: return "figure.walk"
        case .absent: return "xmark.circle.fill"
        case .earlyLeave: return "arrowshape.turn.up.left.fill"
        case .holiday: return "sun.max.fill"
        }
    }

    var isPenalized: Bool {
        switch self {
        case .late, .absent, .earlyLeave: return true
        case .normal, .overtime, .leave, .holiday: return false
        }
    }
}

// MARK: - Income Category
enum IncomeCategory: String, CaseIterable {
    case salary = "salary"
    case overtime = "overtime"
    case bonus = "bonus"
    case allowance = "allowance"
    case commission = "commission"

    var displayName: String {
        switch self {
        case .salary: return "income_category_salary".localized
        case .overtime: return "income_category_overtime".localized
        case .bonus: return "income_category_bonus".localized
        case .allowance: return "income_category_allowance".localized
        case .commission: return "income_category_commission".localized
        }
    }

    var color: Color {
        switch self {
        case .salary: return .blue
        case .overtime: return .orange
        case .bonus: return .green
        case .allowance: return .purple
        case .commission: return .red
        }
    }

    var icon: String {
        switch self {
        case .salary: return "dollarsign.circle.fill"
        case .overtime: return "clock.fill"
        case .bonus: return "star.fill"
        case .allowance: return "plus.circle.fill"
        case .commission: return "percent"
        }
    }
}

// MARK: - Time Tracking Status
enum TimeTrackingStatus: String, CaseIterable {
    case notStarted = "not_started"
    case working = "working"
    case onBreak = "on_break"
    case finished = "finished"
    case paused = "paused"

    var displayText: String {
        switch self {
        case .notStarted: return "time_tracking_not_started".localized
        case .working: return "time_tracking_working".localized
        case .onBreak: return "time_tracking_on_break".localized
        case .finished: return "time_tracking_finished".localized
        case .paused: return "time_tracking_paused".localized
        }
    }

    var color: Color {
        switch self {
        case .notStarted: return .gray
        case .working: return .green
        case .onBreak: return .orange
        case .finished: return .blue
        case .paused: return .yellow
        }
    }

    var icon: String {
        switch self {
        case .notStarted: return "play.circle"
        case .working: return "pause.circle.fill"
        case .onBreak: return "cup.and.saucer.fill"
        case .finished: return "checkmark.circle.fill"
        case .paused: return "pause.circle"
        }
    }

    var actionText: String {
        switch self {
        case .notStarted: return "action_start_work".localized
        case .working: return "action_take_break".localized
        case .onBreak: return "action_resume_work".localized
        case .finished: return "action_start_new_session".localized
        case .paused: return "action_resume_work".localized
        }
    }
}
