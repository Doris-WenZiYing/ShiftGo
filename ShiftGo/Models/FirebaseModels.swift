//
//  FirebaseModels.swift
//  ShiftGo
//
//  Updated by Doris Wen on 2025/9/1.
//

import Foundation
import FirebaseFirestore

// MARK: - Firebase User Model
struct FirebaseUser: Codable, Identifiable {
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
    let createdAt: Timestamp
    let updatedAt: Timestamp

    enum CodingKeys: String, CodingKey {
        case email, name, role, permissions
        case companyId = "company_id"
        case employeeId = "employee_id"
        case isActive = "is_active"
        case hourlyRate = "hourly_rate"
        case employmentType = "employment_type"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    init(id: String = "", email: String, name: String, role: UserRole,
         companyId: String? = nil, employeeId: String? = nil, isActive: Bool = true,
         hourlyRate: Double = 160.0, employmentType: EmploymentType = .partTime,
         permissions: UserPermission = .employeeDefault) {
        self.id = id
        self.email = email
        self.name = name
        self.role = role.rawValue
        self.companyId = companyId
        self.employeeId = employeeId
        self.isActive = isActive
        self.hourlyRate = hourlyRate
        self.employmentType = employmentType.rawValue
        self.permissions = permissions.rawValue
        self.createdAt = Timestamp()
        self.updatedAt = Timestamp()
    }

    static func from(data: [String: Any], uid: String) throws -> FirebaseUser {
        guard let email = data["email"] as? String,
              let name = data["name"] as? String,
              let role = data["role"] as? String,
              let isActive = data["is_active"] as? Bool,
              let hourlyRate = data["hourly_rate"] as? Double,
              let employmentType = data["employment_type"] as? String,
              let permissions = data["permissions"] as? Int,
              let createdAt = data["created_at"] as? Timestamp,
              let updatedAt = data["updated_at"] as? Timestamp else {
            throw FirebaseError.invalidUserData
        }

        let userRole = UserRole(rawValue: role) ?? .employee
        let empType = EmploymentType(rawValue: employmentType) ?? .partTime
        let userPermissions = UserPermission(rawValue: permissions)

        var user = FirebaseUser(
            id: uid,
            email: email,
            name: name,
            role: userRole,
            companyId: data["company_id"] as? String,
            employeeId: data["employee_id"] as? String,
            isActive: isActive,
            hourlyRate: hourlyRate,
            employmentType: empType,
            permissions: userPermissions
        )

        user.id = uid
        return user
    }

    func toLocalUser() -> User {
        return User(
            id: id,
            email: email,
            name: name,
            role: role,
            companyId: companyId,
            employeeId: employeeId,
            isActive: isActive,
            hourlyRate: hourlyRate,
            employmentType: employmentType,
            permissions: permissions,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    func toDictionary() -> [String: Any] {
        return [
            "email": email,
            "name": name,
            "role": role,
            "company_id": companyId ?? NSNull(),
            "employee_id": employeeId ?? NSNull(),
            "is_active": isActive,
            "hourly_rate": hourlyRate,
            "employment_type": employmentType,
            "permissions": permissions,
            "created_at": createdAt,
            "updated_at": updatedAt
        ]
    }
}

// MARK: - Firebase Company Model
struct FirebaseCompany: Codable, Identifiable {
    var id: String = ""
    let name: String
    let ownerId: String
    let inviteCode: String
    let maxEmployees: Int
    let timezone: String
    let createdAt: Timestamp
    let updatedAt: Timestamp

    enum CodingKeys: String, CodingKey {
        case name
        case ownerId = "owner_id"
        case inviteCode = "invite_code"
        case maxEmployees = "max_employees"
        case timezone
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    init(id: String = "", name: String, ownerId: String, inviteCode: String,
         maxEmployees: Int = 50, timezone: String = "Asia/Taipei") {
        self.id = id
        self.name = name
        self.ownerId = ownerId
        self.inviteCode = inviteCode
        self.maxEmployees = maxEmployees
        self.timezone = timezone
        self.createdAt = Timestamp()
        self.updatedAt = Timestamp()
    }

    static func from(data: [String: Any], id: String) throws -> FirebaseCompany {
        guard let name = data["name"] as? String,
              let ownerId = data["owner_id"] as? String,
              let inviteCode = data["invite_code"] as? String,
              let maxEmployees = data["max_employees"] as? Int,
              let timezone = data["timezone"] as? String,
              let createdAt = data["created_at"] as? Timestamp,
              let updatedAt = data["updated_at"] as? Timestamp else {
            throw FirebaseError.invalidCompanyData
        }

        var company = FirebaseCompany(
            id: id,
            name: name,
            ownerId: ownerId,
            inviteCode: inviteCode,
            maxEmployees: maxEmployees,
            timezone: timezone
        )
        company.id = id
        return company
    }

    func toLocalCompany() -> Company {
        return Company(
            id: id,
            name: name,
            ownerId: ownerId,
            inviteCode: inviteCode,
            maxEmployees: maxEmployees,
            timezone: timezone,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    func toDictionary() -> [String: Any] {
        return [
            "name": name,
            "owner_id": ownerId,
            "invite_code": inviteCode,
            "max_employees": maxEmployees,
            "timezone": timezone,
            "created_at": createdAt,
            "updated_at": updatedAt
        ]
    }
}

// MARK: - Firebase Vacation Settings Model
struct FirebaseVacationSettings: Codable, Identifiable {
    var id: String = ""
    let companyId: String
    let targetYear: Int
    let targetMonth: Int
    let maxDaysPerMonth: Int
    let maxDaysPerWeek: Int
    let limitType: String
    let deadline: Timestamp
    let isPublished: Bool
    let publishedAt: Timestamp?
    let createdAt: Timestamp
    let updatedAt: Timestamp

    enum CodingKeys: String, CodingKey {
        case companyId = "company_id"
        case targetYear = "target_year"
        case targetMonth = "target_month"
        case maxDaysPerMonth = "max_days_per_month"
        case maxDaysPerWeek = "max_days_per_week"
        case limitType = "limit_type"
        case deadline, isPublished = "is_published"
        case publishedAt = "published_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    init(companyId: String, targetYear: Int, targetMonth: Int,
         maxDaysPerMonth: Int = 8, maxDaysPerWeek: Int = 0,
         limitType: VacationLimitType = .monthly,
         deadline: Date = Calendar.current.date(byAdding: .day, value: 7, to: Date())!) {
        self.id = ""
        self.companyId = companyId
        self.targetYear = targetYear
        self.targetMonth = targetMonth
        self.maxDaysPerMonth = maxDaysPerMonth
        self.maxDaysPerWeek = maxDaysPerWeek
        self.limitType = limitType.rawValue
        self.deadline = Timestamp(date: deadline)
        self.isPublished = false
        self.publishedAt = nil
        self.createdAt = Timestamp()
        self.updatedAt = Timestamp()
    }

    func toVacationSettings() -> VacationSettings {
        let limitTypeEnum: VacationLimitType
        if maxDaysPerMonth > 0 && maxDaysPerWeek > 0 {
            limitTypeEnum = .flexible
        } else if maxDaysPerMonth > 0 {
            limitTypeEnum = .monthly
        } else if maxDaysPerWeek > 0 {
            limitTypeEnum = .weekly
        } else {
            limitTypeEnum = .monthly
        }

        let yearMonth = YearMonth(year: targetYear, month: targetMonth)

        return VacationSettings(
            targetMonth: yearMonth.localizedMonthString,
            targetYear: targetYear,
            maxDaysPerMonth: maxDaysPerMonth,
            maxDaysPerWeek: maxDaysPerWeek,
            limitType: limitTypeEnum,
            deadline: deadline.dateValue(),
            isPublished: isPublished,
            publishedAt: publishedAt?.dateValue()
        )
    }
}

// MARK: - Firebase Vacation Request Model
struct FirebaseVacationRequest: Codable, Identifiable {
    var id: String = ""
    let companyId: String
    let userId: String
    let employeeName: String
    let employeeId: String
    let targetYear: Int
    let targetMonth: Int
    let vacationDates: [String]
    let note: String
    let status: String
    let submitDate: Timestamp
    let reviewedAt: Timestamp?
    let reviewedBy: String?
    let reviewNote: String?
    let createdAt: Timestamp
    let updatedAt: Timestamp

    enum CodingKeys: String, CodingKey {
        case companyId = "company_id"
        case userId = "user_id"
        case employeeName = "employee_name"
        case employeeId = "employee_id"
        case targetYear = "target_year"
        case targetMonth = "target_month"
        case vacationDates = "vacation_dates"
        case note, status
        case submitDate = "submit_date"
        case reviewedAt = "reviewed_at"
        case reviewedBy = "reviewed_by"
        case reviewNote = "review_note"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    init(companyId: String, userId: String, employeeName: String, employeeId: String,
         targetYear: Int, targetMonth: Int, vacationDates: [String], note: String = "") {
        self.id = ""
        self.companyId = companyId
        self.userId = userId
        self.employeeName = employeeName
        self.employeeId = employeeId
        self.targetYear = targetYear
        self.targetMonth = targetMonth
        self.vacationDates = vacationDates
        self.note = note
        self.status = "pending"
        self.submitDate = Timestamp()
        self.reviewedAt = nil
        self.reviewedBy = nil
        self.reviewNote = nil
        self.createdAt = Timestamp()
        self.updatedAt = Timestamp()
    }

    func toEmployeeVacation() -> EmployeeVacation {
        let vacationStatus: EmployeeVacation.VacationRequestStatus
        switch status {
        case "approved": vacationStatus = .approved
        case "rejected": vacationStatus = .rejected
        case "cancelled": vacationStatus = .cancelled
        default: vacationStatus = .pending
        }

        return EmployeeVacation(
            employeeName: employeeName,
            employeeId: employeeId,
            dates: Set(vacationDates),
            submitDate: submitDate.dateValue(),
            status: vacationStatus,
            note: note,
            reviewNote: reviewNote
        )
    }
}
