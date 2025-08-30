//
//  FirebaseModels.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/8/29.
//

import Foundation
import FirebaseFirestore

// MARK: - 使用者模型
struct User: Codable, Identifiable {
    @DocumentID var id: String?
    let email: String
    let name: String
    let role: String // "employee" 或 "boss"
    let companyId: String
    let employeeId: String? // 員工編號，只有員工需要
    let createdAt: Timestamp
    let updatedAt: Timestamp

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case name
        case role
        case companyId = "company_id"
        case employeeId = "employee_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - 公司模型
struct Company: Codable, Identifiable {
    @DocumentID var id: String?
    let name: String
    let createdAt: Timestamp
    let updatedAt: Timestamp

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - 排休設定模型 (修復版)
struct FirebaseVacationSettings: Codable, Identifiable {
    @DocumentID var id: String?
    let companyId: String
    let targetYear: Int
    let targetMonth: Int
    let maxDaysPerMonth: Int
    let maxDaysPerWeek: Int
    let limitType: String // "weekly" 或 "monthly"
    let deadline: Timestamp
    let isPublished: Bool
    let publishedAt: Timestamp?
    let createdAt: Timestamp
    let updatedAt: Timestamp

    enum CodingKeys: String, CodingKey {
        case id
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

    // 手動初始化器確保所有欄位都正確設置
    init(companyId: String, targetYear: Int, targetMonth: Int, maxDaysPerMonth: Int,
         maxDaysPerWeek: Int, limitType: String, deadline: Timestamp, isPublished: Bool,
         publishedAt: Timestamp?, createdAt: Timestamp, updatedAt: Timestamp) {
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

// MARK: - 排休申請模型 (修復版 - 添加容錯處理)
struct FirebaseVacationRequest: Codable, Identifiable {
    @DocumentID var id: String?
    let companyId: String
    let userId: String
    let employeeName: String
    let employeeId: String
    let targetYear: Int
    let targetMonth: Int
    let vacationDates: [String] // 格式: ["2025-08-15", "2025-08-16"]
    let note: String
    let status: String // "pending", "approved", "rejected"
    let submitDate: Timestamp
    let reviewedAt: Timestamp?
    let reviewedBy: String? // 審核者的 userId
    let createdAt: Timestamp
    let updatedAt: Timestamp

    enum CodingKeys: String, CodingKey {
        case id
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

    // 手動初始化器
    init(companyId: String, userId: String, employeeName: String, employeeId: String,
         targetYear: Int, targetMonth: Int, vacationDates: [String], note: String,
         status: String, submitDate: Timestamp, reviewedAt: Timestamp?,
         reviewedBy: String?, createdAt: Timestamp, updatedAt: Timestamp) {
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

    // 自定義解碼器 - 處理缺失欄位
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

// MARK: - 轉換擴展
extension FirebaseVacationRequest {
    // 轉換成本地的 EmployeeVacation 模型
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
    // 轉換成本地的 VacationSettings 模型
    func toVacationSettings() -> VacationSettings {
        let months = [
            1: "1月", 2: "2月", 3: "3月", 4: "4月",
            5: "5月", 6: "6月", 7: "7月", 8: "8月",
            9: "9月", 10: "10月", 11: "11月", 12: "12月"
        ]

        let limitTypeEnum: VacationLimitType = limitType == "weekly" ? .weekly : .monthly

        return VacationSettings(
            targetMonth: months[targetMonth] ?? "",
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

// MARK: - 本地模型轉Firebase擴展 (修復版)
extension VacationSettings {
    func toFirebaseVacationSettings(companyId: String) -> FirebaseVacationSettings {
        let monthNumber = getMonthNumber(from: targetMonth)
        let limitTypeString = limitType == .weekly ? "weekly" : "monthly"
        let now = Timestamp()

        print("🔄 Converting VacationSettings to Firebase:")
        print("   - Target: \(targetYear)/\(monthNumber) (\(targetMonth))")
        print("   - isPublished: \(isPublished)")
        print("   - publishedAt: \(publishedAt?.description ?? "nil")")

        return FirebaseVacationSettings(
            companyId: companyId,
            targetYear: targetYear,
            targetMonth: monthNumber,
            maxDaysPerMonth: maxDaysPerMonth,
            maxDaysPerWeek: maxDaysPerWeek,
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
        }
    }
}
