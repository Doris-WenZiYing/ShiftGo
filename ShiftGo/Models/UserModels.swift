//
//  UserModels.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/8/25.
//

import Foundation
import SwiftUI
import FirebaseFirestore

// MARK: - User Permission
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

    var displayName: String {
        var names: [String] = []
        if contains(.viewSchedule) { names.append("permission_view_schedule".localized) }
        if contains(.requestVacation) { names.append("permission_request_vacation".localized) }
        if contains(.manageEmployees) { names.append("permission_manage_employees".localized) }
        if contains(.generateSchedule) { names.append("permission_generate_schedule".localized) }
        if contains(.viewReports) { names.append("permission_view_reports".localized) }
        if contains(.manageCompany) { names.append("permission_manage_company".localized) }
        return names.joined(separator: ", ")
    }
}

// MARK: - Employee Update Data
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

// MARK: - User Statistics
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

// MARK: - Local User Model
struct User: Identifiable {
    var id: String = ""
    let email: String
    let name: String
    let role: String
    let companyId: String?
    let employeeId: String?
    let isActive: Bool
    let hourlyRate: Double
    let employmentType: String
    let permissions: Int
    let profileImageURL: String?
    let phoneNumber: String?
    let department: String?
    let createdAt: Timestamp
    let updatedAt: Timestamp

    init(id: String = "", email: String, name: String, role: String,
         companyId: String? = nil, employeeId: String? = nil, isActive: Bool = true,
         hourlyRate: Double = 160.0, employmentType: String = "part_time",
         permissions: Int = UserPermission.employeeDefault.rawValue,
         profileImageURL: String? = nil, phoneNumber: String? = nil,
         department: String? = nil,
         createdAt: Timestamp = Timestamp(), updatedAt: Timestamp = Timestamp()) {
        self.id = id
        self.email = email
        self.name = name
        self.role = role
        self.companyId = companyId
        self.employeeId = employeeId
        self.isActive = isActive
        self.hourlyRate = hourlyRate
        self.employmentType = employmentType
        self.permissions = permissions
        self.profileImageURL = profileImageURL
        self.phoneNumber = phoneNumber
        self.department = department
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var userRole: UserRole {
        return UserRole(rawValue: role) ?? .employee
    }

    var isBoss: Bool {
        return role == UserRole.boss.rawValue
    }

    var employmentTypeDisplay: String {
        switch employmentType {
        case "full_time": return "employment_type_full_time".localized
        case "part_time": return "employment_type_part_time".localized
        default: return "employment_type_part_time".localized
        }
    }

    var userPermissions: UserPermission {
        return UserPermission(rawValue: permissions)
    }

    var displayName: String {
        return name.isEmpty ? email : name
    }

    static func guestUser() -> User {
        return User(
            id: "guest",
            email: "guest@demo.com",
            name: "guest_user".localized,
            role: UserRole.employee.rawValue,
            companyId: "demo_company",
            employeeId: "GUEST001"
        )
    }

    func canPerform(_ permission: UserPermission) -> Bool {
        return userPermissions.contains(permission)
    }

    func update(with data: EmployeeUpdateData) -> User {
        return User(
            id: id,
            email: email,
            name: data.name ?? name,
            role: role,
            companyId: companyId,
            employeeId: employeeId,
            isActive: data.isActive ?? isActive,
            hourlyRate: data.hourlyRate ?? hourlyRate,
            employmentType: data.employmentType?.rawValue ?? employmentType,
            permissions: data.permissions?.rawValue ?? permissions,
            profileImageURL: profileImageURL,
            phoneNumber: phoneNumber,
            department: department,
            createdAt: createdAt,
            updatedAt: Timestamp()
        )
    }
}

// MARK: - User Codable Extension
extension User: Codable {
    enum CodingKeys: String, CodingKey {
        case id, email, name, role, permissions
        case companyId = "company_id"
        case employeeId = "employee_id"
        case isActive = "is_active"
        case hourlyRate = "hourly_rate"
        case employmentType = "employment_type"
        case profileImageURL = "profile_image_url"
        case phoneNumber = "phone_number"
        case department
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        email = try container.decode(String.self, forKey: .email)
        name = try container.decode(String.self, forKey: .name)
        role = try container.decode(String.self, forKey: .role)
        companyId = try container.decodeIfPresent(String.self, forKey: .companyId)
        employeeId = try container.decodeIfPresent(String.self, forKey: .employeeId)
        isActive = try container.decodeIfPresent(Bool.self, forKey: .isActive) ?? true
        hourlyRate = try container.decodeIfPresent(Double.self, forKey: .hourlyRate) ?? 160.0
        employmentType = try container.decodeIfPresent(String.self, forKey: .employmentType) ?? "part_time"
        permissions = try container.decodeIfPresent(Int.self, forKey: .permissions) ?? UserPermission.employeeDefault.rawValue
        profileImageURL = try container.decodeIfPresent(String.self, forKey: .profileImageURL)
        phoneNumber = try container.decodeIfPresent(String.self, forKey: .phoneNumber)
        department = try container.decodeIfPresent(String.self, forKey: .department)
        createdAt = try container.decodeIfPresent(Timestamp.self, forKey: .createdAt) ?? Timestamp()
        updatedAt = try container.decodeIfPresent(Timestamp.self, forKey: .updatedAt) ?? Timestamp()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(email, forKey: .email)
        try container.encode(name, forKey: .name)
        try container.encode(role, forKey: .role)
        try container.encodeIfPresent(companyId, forKey: .companyId)
        try container.encodeIfPresent(employeeId, forKey: .employeeId)
        try container.encode(isActive, forKey: .isActive)
        try container.encode(hourlyRate, forKey: .hourlyRate)
        try container.encode(employmentType, forKey: .employmentType)
        try container.encode(permissions, forKey: .permissions)
        try container.encodeIfPresent(profileImageURL, forKey: .profileImageURL)
        try container.encodeIfPresent(phoneNumber, forKey: .phoneNumber)
        try container.encodeIfPresent(department, forKey: .department)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
    }
}

// MARK: - Team Member
struct TeamMember: Identifiable {
    let id: String
    let name: String
    let role: UserRole
    let employmentType: EmploymentType
    let status: UserStatus
    let hourlyRate: Double
    let totalHoursThisMonth: Int
    let lastActive: Date
    let profileImageURL: String?

    var statusColor: Color { status.color }
    var roleIcon: String { role.icon }
    var isOnline: Bool { Date().timeIntervalSince(lastActive) < 300 } // 5 minutes
}
