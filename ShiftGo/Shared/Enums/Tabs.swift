//
//  Tabs.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/8/25.
//

import Foundation

enum EmployeeTab: String, CaseIterable {
    case calendar = "calendar"
    case reports = "reports"
    case templates = "timetracker" // 🔥 更新 rawValue
    case more = "more"

    var icon: String {
        switch self {
        case .calendar: return "calendar"
        case .reports: return "chart.bar"
        case .templates: return "clock.fill" // 🔥 更新圖標
        case .more: return "line.3.horizontal"
        }
    }

    var label: String {
        switch self {
        case .calendar: return "Calendar"
        case .reports: return "Reports"
        case .templates: return "Time Tracker" // 🔥 更新標籤
        case .more: return "More"
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
        case .dashboard: return "Dashboard"
        case .employees: return "Employees"
        case .schedules: return "Schedules"
        case .analytics: return "Analytics"
        case .more: return "More"
        }
    }
}
