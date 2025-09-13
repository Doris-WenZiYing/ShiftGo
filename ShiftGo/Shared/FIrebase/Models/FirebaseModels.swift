//
//  FirebaseModels.swift
//  ShiftGo
//
//  Updated by Doris Wen on 2025/9/1.
//

import Foundation
import FirebaseFirestore

// MARK: - User
struct User: Codable, Identifiable {
    var id: String = ""  // 手動管理 ID，避免 @DocumentID 警告
    let email: String
    let name: String
    let role: String // "employee" 或 "boss"
    let companyId: String?
    let employeeId: String?
    let isActive: Bool
    let hourlyRate: Double
    let employmentType: String
    let createdAt: Timestamp
    let updatedAt: Timestamp

    enum CodingKeys: String, CodingKey {
        case email
        case name
        case role
        case companyId = "company_id"
        case employeeId = "employee_id"
        case isActive = "is_active"
        case hourlyRate = "hourly_rate"
        case employmentType = "employment_type"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        // 注意：id 不在 CodingKeys 中，因為它由文檔 ID 設置
    }

    // 🔧 修復：自定義初始化器
    init(id: String = "", email: String, name: String, role: String,
         companyId: String? = nil, employeeId: String? = nil, isActive: Bool = true,
         hourlyRate: Double = 160.0, employmentType: String = "part_time",
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
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // 轉換為本地 UserRole
    var userRole: UserRole {
        return UserRole(rawValue: role) ?? .employee
    }

    // 是否為老闆
    var isBoss: Bool {
        return role == UserRole.boss.rawValue
    }

    // 顯示用的員工類型
    var employmentTypeDisplay: String {
        switch employmentType {
        case "full_time":
            return "正職"
        case "part_time":
            return "兼職"
        default:
            return "兼職"
        }
    }

    // 靜態方法創建訪客用戶
    static func guestUser() -> User {
        return User(
            id: "guest",
            email: "guest@demo.com",
            name: "訪客用戶",
            role: UserRole.employee.rawValue,
            companyId: "demo_company",
            employeeId: "GUEST001",
            isActive: true,
            hourlyRate: 160.0,
            employmentType: "part_time"
        )
    }

    // 從 Firebase 資料建立 User
    static func from(data: [String: Any], uid: String) throws -> User {
        guard let email = data["email"] as? String,
              let name = data["name"] as? String,
              let role = data["role"] as? String,
              let createdAt = data["created_at"] as? Timestamp,
              let updatedAt = data["updated_at"] as? Timestamp else {
            throw FirebaseError.invalidUserData
        }

        return User(
            id: uid, // 使用文檔 ID
            email: email,
            name: name,
            role: role,
            companyId: data["company_id"] as? String,
            employeeId: data["employee_id"] as? String,
            isActive: data["is_active"] as? Bool ?? true,
            hourlyRate: data["hourly_rate"] as? Double ?? 160.0,
            employmentType: data["employment_type"] as? String ?? "part_time",
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

// MARK: - 公司模型 (修復版)
struct Company: Codable, Identifiable {
    // 🔧 修復：手動管理 ID
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
         maxEmployees: Int = 5, timezone: String = "Asia/Taipei",
         createdAt: Timestamp = Timestamp(), updatedAt: Timestamp = Timestamp()) {
        self.id = id
        self.name = name
        self.ownerId = ownerId
        self.inviteCode = inviteCode
        self.maxEmployees = maxEmployees
        self.timezone = timezone
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // 創建示範公司
    static func demoCompany() -> Company {
        return Company(
            id: "demo_company",
            name: "示範咖啡廳",
            ownerId: "demo_owner",
            inviteCode: "DEMO01",
            maxEmployees: 5,
            timezone: "Asia/Taipei"
        )
    }

    // 從 Firebase 資料建立 Company
    static func from(data: [String: Any], id: String) throws -> Company {
        guard let name = data["name"] as? String,
              let ownerId = data["owner_id"] as? String,
              let inviteCode = data["invite_code"] as? String,
              let maxEmployees = data["max_employees"] as? Int,
              let timezone = data["timezone"] as? String,
              let createdAt = data["created_at"] as? Timestamp,
              let updatedAt = data["updated_at"] as? Timestamp else {
            throw FirebaseError.invalidCompanyData
        }

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
}

// MARK: - 排休設定模型 (修復版)
struct FirebaseVacationSettings: Codable, Identifiable {
    // 🔧 修復：手動管理 ID
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
        case deadline
        case isPublished = "is_published"
        case publishedAt = "published_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    init(id: String = "", companyId: String, targetYear: Int, targetMonth: Int,
         maxDaysPerMonth: Int, maxDaysPerWeek: Int, limitType: String,
         deadline: Timestamp, isPublished: Bool, publishedAt: Timestamp?,
         createdAt: Timestamp = Timestamp(), updatedAt: Timestamp = Timestamp()) {
        self.id = id
        self.companyId = companyId
        self.targetYear = targetYear
        self.targetMonth = targetMonth
        self.maxDaysPerMonth = maxDaysPerMonth
        self.maxDaysPerWeek = maxDaysPerWeek
        self.limitType = limitType
        self.deadline = deadline
        self.isPublished = isPublished
        self.publishedAt = publishedAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - 排休申請模型 (修復版)
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
        case note
        case status
        case submitDate = "submit_date"
        case reviewedAt = "reviewed_at"
        case reviewedBy = "reviewed_by"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    init(id: String = "", companyId: String, userId: String, employeeName: String,
         employeeId: String, targetYear: Int, targetMonth: Int, vacationDates: [String],
         note: String, status: String, submitDate: Timestamp = Timestamp(),
         reviewedAt: Timestamp? = nil, reviewedBy: String? = nil,
         createdAt: Timestamp = Timestamp(), updatedAt: Timestamp = Timestamp()) {
        self.id = id
        self.companyId = companyId
        self.userId = userId
        self.employeeName = employeeName
        self.employeeId = employeeId
        self.targetYear = targetYear
        self.targetMonth = targetMonth
        self.vacationDates = vacationDates
        self.note = note
        self.status = status
        self.submitDate = submitDate
        self.reviewedAt = reviewedAt
        self.reviewedBy = reviewedBy
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // 自定義解碼器處理缺失欄位
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // 必需欄位
        companyId = try container.decode(String.self, forKey: .companyId)
        userId = try container.decode(String.self, forKey: .userId)
        employeeName = try container.decode(String.self, forKey: .employeeName)
        employeeId = try container.decode(String.self, forKey: .employeeId)

        // 可能缺失的欄位，提供默認值
        targetYear = try container.decodeIfPresent(Int.self, forKey: .targetYear) ?? 2025
        targetMonth = try container.decodeIfPresent(Int.self, forKey: .targetMonth) ?? 8
        vacationDates = try container.decodeIfPresent([String].self, forKey: .vacationDates) ?? []
        note = try container.decodeIfPresent(String.self, forKey: .note) ?? ""
        status = try container.decodeIfPresent(String.self, forKey: .status) ?? "pending"

        // 時間戳欄位
        submitDate = try container.decodeIfPresent(Timestamp.self, forKey: .submitDate) ?? Timestamp()
        reviewedAt = try container.decodeIfPresent(Timestamp.self, forKey: .reviewedAt)
        reviewedBy = try container.decodeIfPresent(String.self, forKey: .reviewedBy)
        createdAt = try container.decodeIfPresent(Timestamp.self, forKey: .createdAt) ?? Timestamp()
        updatedAt = try container.decodeIfPresent(Timestamp.self, forKey: .updatedAt) ?? Timestamp()
    }
}

// MARK: - 員工統計模型
struct CompanyStats {
    let totalEmployees: Int
    let activeEmployees: Int
    let fullTimeEmployees: Int
    let partTimeEmployees: Int
    let averageHourlyRate: Double

    init(totalEmployees: Int = 0, activeEmployees: Int = 0, fullTimeEmployees: Int = 0,
         partTimeEmployees: Int = 0, averageHourlyRate: Double = 0) {
        self.totalEmployees = totalEmployees
        self.activeEmployees = activeEmployees
        self.fullTimeEmployees = fullTimeEmployees
        self.partTimeEmployees = partTimeEmployees
        self.averageHourlyRate = averageHourlyRate
    }
}

// MARK: - 員工更新資料結構
struct EmployeeUpdateData {
    let name: String?
    let hourlyRate: Double?
    let employmentType: EmploymentType?
    let isActive: Bool?

    init(name: String? = nil, hourlyRate: Double? = nil, employmentType: EmploymentType? = nil, isActive: Bool? = nil) {
        self.name = name
        self.hourlyRate = hourlyRate
        self.employmentType = employmentType
        self.isActive = isActive
    }
}

// MARK: - 員工類型枚舉
enum EmploymentType: String, CaseIterable {
    case fullTime = "full_time"
    case partTime = "part_time"

    var displayName: String {
        switch self {
        case .fullTime:
            return "正職"
        case .partTime:
            return "兼職"
        }
    }
}

// MARK: - 轉換擴展
extension FirebaseVacationRequest {
    func toEmployeeVacation() -> EmployeeVacation {
        let vacationStatus: EmployeeVacation.VacationRequestStatus
        switch status {
        case "approved":
            vacationStatus = .approved
        case "rejected":
            vacationStatus = .rejected
        default:
            vacationStatus = .pending
        }

        return EmployeeVacation(
            employeeName: employeeName,
            employeeId: employeeId,
            dates: Set(vacationDates),
            submitDate: submitDate.dateValue(),
            status: vacationStatus,
            note: note
        )
    }
}

extension FirebaseVacationSettings {
    // 🔥 更新：轉換成本地的 VacationSettings 模型
    func toVacationSettings() -> VacationSettings {
        let months = [
            1: "1月", 2: "2月", 3: "3月", 4: "4月",
            5: "5月", 6: "6月", 7: "7月", 8: "8月",
            9: "9月", 10: "10月", 11: "11月", 12: "12月"
        ]

        // 🔥 根據限制值決定限制類型
        let limitTypeEnum: VacationLimitType
        if maxDaysPerMonth > 0 && maxDaysPerWeek > 0 {
            limitTypeEnum = .flexible
        } else if maxDaysPerMonth > 0 {
            limitTypeEnum = .monthly
        } else if maxDaysPerWeek > 0 {
            limitTypeEnum = .weekly
        } else {
            // 預設為月限制
            limitTypeEnum = .monthly
        }

        return VacationSettings(
            targetMonth: months[targetMonth] ?? "",
            targetYear: targetYear,
            maxDaysPerMonth: maxDaysPerMonth, // 🔥 保留原始值，0 表示無限制
            maxDaysPerWeek: maxDaysPerWeek,   // 🔥 保留原始值，0 表示無限制
            limitType: limitTypeEnum,
            deadline: deadline.dateValue(),
            isPublished: isPublished,
            publishedAt: publishedAt?.dateValue()
        )
    }
}

extension FirebaseVacationSettings {
    /// 檢查是否有月限制
    var hasMonthlyLimit: Bool {
        return maxDaysPerMonth > 0
    }

    /// 檢查是否有週限制
    var hasWeeklyLimit: Bool {
        return maxDaysPerWeek > 0
    }

    /// 獲取限制描述
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

    /// 驗證設定的有效性
    func validate() -> Bool {
        // 至少要有一種限制
        guard hasMonthlyLimit || hasWeeklyLimit else {
            return false
        }

        // 月限制應該合理（1-31天）
        if hasMonthlyLimit && (maxDaysPerMonth < 1 || maxDaysPerMonth > 31) {
            return false
        }

        // 週限制應該合理（1-7天）
        if hasWeeklyLimit && (maxDaysPerWeek < 1 || maxDaysPerWeek > 7) {
            return false
        }

        return true
    }
}

extension VacationSettings {
    // 🔥 更新：支援彈性限制的轉換
    func toFirebaseVacationSettings(companyId: String) -> FirebaseVacationSettings {
        let monthNumber = getMonthNumber(from: targetMonth)

        // 🔥 根據實際啟用的限制設定 limitType
        let limitTypeString: String
        if hasMonthlyLimit && hasWeeklyLimit {
            limitTypeString = "flexible"
        } else if hasMonthlyLimit {
            limitTypeString = "monthly"
        } else if hasWeeklyLimit {
            limitTypeString = "weekly"
        } else {
            limitTypeString = "monthly" // 預設
        }

        let now = Timestamp()

        print("🔄 Converting VacationSettings to Firebase:")
        print("   - Target: \(targetYear)/\(monthNumber) (\(targetMonth))")
        print("   - Monthly limit: \(maxDaysPerMonth) (enabled: \(hasMonthlyLimit))")
        print("   - Weekly limit: \(maxDaysPerWeek) (enabled: \(hasWeeklyLimit))")
        print("   - Limit type: \(limitTypeString)")
        print("   - isPublished: \(isPublished)")
        print("   - publishedAt: \(publishedAt?.description ?? "nil")")

        return FirebaseVacationSettings(
            companyId: companyId,
            targetYear: targetYear,
            targetMonth: monthNumber,
            maxDaysPerMonth: maxDaysPerMonth, // 🔥 保留原始值，包括 0
            maxDaysPerWeek: maxDaysPerWeek,   // 🔥 保留原始值，包括 0
            limitType: limitTypeString,
            deadline: Timestamp(date: deadline),
            isPublished: isPublished, // 確保這裡正確傳遞
            publishedAt: publishedAt != nil ? Timestamp(date: publishedAt!) : nil,
            createdAt: now,
            updatedAt: now
        )
    }

    private func getMonthNumber(from monthString: String) -> Int {
        let monthMap = [
            "1月": 1, "2月": 2, "3月": 3, "4月": 4,
            "5月": 5, "6月": 6, "7月": 7, "8月": 8,
            "9月": 9, "10月": 10, "11月": 11, "12月": 12
        ]
        return monthMap[monthString] ?? 1
    }
}

// MARK: - 錯誤類型
enum FirebaseError: LocalizedError {
    case userNotFound
    case invalidCompany
    case permissionDenied
    case vacationSettingsNotFound
    case networkError(String)
    case unknown(String)
    case invalidEmail
    case weakPassword
    case emailAlreadyInUse
    case invalidCredentials
    case invalidInviteCode
    case invalidUserData
    case invalidCompanyData

    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "找不到使用者"
        case .invalidCompany:
            return "無效的公司"
        case .permissionDenied:
            return "沒有權限執行此操作"
        case .vacationSettingsNotFound:
            return "找不到排休設定"
        case .networkError(let message):
            return "網路錯誤：\(message)"
        case .unknown(let message):
            return "未知錯誤：\(message)"
        case .invalidEmail:
            return "無效的電子郵件格式"
        case .weakPassword:
            return "密碼強度不足，請使用至少6個字符"
        case .emailAlreadyInUse:
            return "此電子郵件已被註冊"
        case .invalidCredentials:
            return "電子郵件或密碼錯誤"
        case .invalidInviteCode:
            return "無效的邀請碼"
        case .invalidUserData:
            return "用戶資料格式錯誤"
        case .invalidCompanyData:
            return "公司資料格式錯誤"
        }
    }

    static func from(_ error: Error) -> FirebaseError {
        if let authError = error as? FirebaseError {
            return authError
        }

        if let nsError = error as NSError? {
            switch nsError.code {
            case 17008:
                return .invalidEmail
            case 17026:
                return .weakPassword
            case 17007:
                return .emailAlreadyInUse
            case 17009:
                return .invalidCredentials
            case 17011:
                return .userNotFound
            case 17020:
                return .networkError(nsError.localizedDescription)
            default:
                return .unknown(nsError.localizedDescription)
            }
        }

        return .unknown(error.localizedDescription)
    }
}
