//
//  UserEnums.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/9/18.
//

import Foundation
import SwiftUI

// MARK: - User Role
enum UserRole: String, CaseIterable, Codable {
    case employee = "employee"
    case boss = "boss"

    var displayName: String {
        switch self {
        case .employee: return "Employee"
        case .boss: return "Boss"
        }
    }

    var localizedName: String {
        switch self {
        case .employee: return "user_role_employee".localized
        case .boss: return "user_role_boss".localized
        }
    }

    var icon: String {
        switch self {
        case .employee: return "person.fill"
        case .boss: return "crown.fill"
        }
    }

    var color: Color {
        switch self {
        case .employee: return AppColors.Theme.primary
        case .boss: return .purple
        }
    }
}

// MARK: - Employment Type
enum EmploymentType: String, CaseIterable, Codable {
    case fullTime = "full_time"
    case partTime = "part_time"

    var displayName: String {
        switch self {
        case .fullTime: return "employment_type_full_time".localized
        case .partTime: return "employment_type_part_time".localized
        }
    }

    var icon: String {
        switch self {
        case .fullTime: return "briefcase.fill"
        case .partTime: return "briefcase"
        }
    }
}

// MARK: - User Status
enum UserStatus: String, CaseIterable, Codable {
    case active = "active"
    case inactive = "inactive"
    case pending = "pending"
    case suspended = "suspended"

    var displayName: String {
        switch self {
        case .active: return "user_status_active".localized
        case .inactive: return "user_status_inactive".localized
        case .pending: return "user_status_pending".localized
        case .suspended: return "user_status_suspended".localized
        }
    }

    var color: Color {
        switch self {
        case .active: return .green
        case .inactive: return .gray
        case .pending: return .orange
        case .suspended: return .red
        }
    }
}

// MARK: - Employee Vacation Status
enum EmployeeVacationStatus {
    case notSubmitted
    case pending
    case approved
    case rejected
    case expired
    case cancelled

    var displayText: String {
        switch self {
        case .notSubmitted: return "vacation_status_not_submitted".localized
        case .pending: return "vacation_status_pending".localized
        case .approved: return "vacation_status_approved".localized
        case .rejected: return "vacation_status_rejected".localized
        case .expired: return "vacation_status_expired".localized
        case .cancelled: return "vacation_status_cancelled".localized
        }
    }

    var color: Color {
        switch self {
        case .notSubmitted: return .gray
        case .pending: return .orange
        case .approved: return .green
        case .rejected: return .red
        case .expired: return .gray
        case .cancelled: return .gray
        }
    }

    var icon: String {
        switch self {
        case .notSubmitted: return "calendar.badge.plus"
        case .pending: return "clock.badge.questionmark"
        case .approved: return "checkmark.circle.fill"
        case .rejected: return "xmark.circle.fill"
        case .expired: return "calendar.badge.exclamationmark"
        case .cancelled: return "minus.circle.fill"
        }
    }
}

//
//  CalendarEnums.swift
//  ShiftGo
//
//  Refactored: Stage 2 - Calendar Related Enums
//

import Foundation
import SwiftUI

// MARK: - Week Enum
public enum Week: Int, CaseIterable {
    case sun = 0, mon = 1, tue = 2, wed = 3, thu = 4, fri = 5, sat = 6

    public var shortString: String {
        DateFormatter().shortWeekdaySymbols[self.rawValue]
    }

    public func shortString(locale: Locale) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        return formatter.shortWeekdaySymbols[self.rawValue]
    }

    public var localizedName: String {
        switch self {
        case .sun: return "day_sunday".localized
        case .mon: return "day_monday".localized
        case .tue: return "day_tuesday".localized
        case .wed: return "day_wednesday".localized
        case .thu: return "day_thursday".localized
        case .fri: return "day_friday".localized
        case .sat: return "day_saturday".localized
        }
    }

    public var shortLocalizedName: String {
        switch self {
        case .sun: return "day_short_sunday".localized
        case .mon: return "day_short_monday".localized
        case .tue: return "day_short_tuesday".localized
        case .wed: return "day_short_wednesday".localized
        case .thu: return "day_short_thursday".localized
        case .fri: return "day_short_friday".localized
        case .sat: return "day_short_saturday".localized
        }
    }

    public var isWeekend: Bool {
        return self == .sun || self == .sat
    }
}

// MARK: - Orientation
public enum Orientation {
    case horizontal
    case vertical
}

// MARK: - Header Size
public enum HeaderSize {
    case zero
    case ratio
    case fixHeight(CGFloat)
}
