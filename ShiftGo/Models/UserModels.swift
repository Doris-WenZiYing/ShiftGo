//
//  UserModels.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/8/25.
//

import Foundation
import SwiftUI

// MARK: - 用戶角色
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
        case .employee: return "員工"
        case .boss: return "主管"
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

// MARK: - 員工類型
enum EmploymentType: String, CaseIterable, Codable {
    case fullTime = "full_time"
    case partTime = "part_time"

    var displayName: String {
        switch self {
        case .fullTime: return "正職"
        case .partTime: return "兼職"
        }
    }

    var icon: String {
        switch self {
        case .fullTime: return "briefcase.fill"
        case .partTime: return "briefcase"
        }
    }
}

// MARK: - 用戶狀態
enum UserStatus: String, CaseIterable, Codable {
    case active = "active"
    case inactive = "inactive"
    case pending = "pending"
    case suspended = "suspended"

    var displayName: String {
        switch self {
        case .active: return "活躍"
        case .inactive: return "停用"
        case .pending: return "待驗證"
        case .suspended: return "暫停"
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

// MARK: - 用戶權限
struct UserPermission: OptionSet, Codable {
    let rawValue: Int

    static let viewSchedule = UserPermission(rawValue: 1 << 0)
    static let requestVacation = UserPermission(rawValue: 1 << 1)
    static let manageEmployees = UserPermission(rawValue: 1 << 2)
    static let generateSchedule = UserPermission(rawValue: 1 << 3)
    static let viewReports = UserPermission(rawValue: 1 << 4)
    static let manageCompany = UserPermission(rawValue: 1 << 5)

    static let employeeDefault: UserPermission = [.viewSchedule, .requestVacation, .viewReports]
    static let bossDefault: UserPermission = [.viewSchedule, .requestVacation, .manageEmployees, .generateSchedule, .viewReports, .manageCompany]
}

// MARK: - 用戶資料更新結構
struct EmployeeUpdateData {
    let name: String?
    let hourlyRate: Double?
    let employmentType: EmploymentType?
    let isActive: Bool?
    let permissions: UserPermission?

    init(name: String? = nil, hourlyRate: Double? = nil, employmentType: EmploymentType? = nil,
         isActive: Bool? = nil, permissions: UserPermission? = nil) {
        self.name = name
        self.hourlyRate = hourlyRate
        self.employmentType = employmentType
        self.isActive = isActive
        self.permissions = permissions
    }
}

// MARK: - 用戶統計
struct UserStatistics {
    let totalUsers: Int
    let activeUsers: Int
    let employeeCount: Int
    let bossCount: Int
    let fullTimeCount: Int
    let partTimeCount: Int
    let averageHourlyRate: Double

    init(totalUsers: Int = 0, activeUsers: Int = 0, employeeCount: Int = 0,
         bossCount: Int = 0, fullTimeCount: Int = 0, partTimeCount: Int = 0,
         averageHourlyRate: Double = 0) {
        self.totalUsers = totalUsers
        self.activeUsers = activeUsers
        self.employeeCount = employeeCount
        self.bossCount = bossCount
        self.fullTimeCount = fullTimeCount
        self.partTimeCount = partTimeCount
        self.averageHourlyRate = averageHourlyRate
    }

    var inactiveUsers: Int { totalUsers - activeUsers }
    var activityRate: Double { totalUsers > 0 ? Double(activeUsers) / Double(totalUsers) : 0 }
}
