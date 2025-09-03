//
//  CompanyManager.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/9/1.
//

import SwiftUI
import Combine
import FirebaseFirestore
import FirebaseAuth

@MainActor
class CompanyManager: ObservableObject {

    // MARK: - Published Properties
    @Published var employees: [User] = []
    @Published var companyStats: CompanyStats = CompanyStats()
    @Published var isLoading = false
    @Published var error: CompanyError?

    // MARK: - Private Properties
    private let firebaseService = FirebaseService.shared
    private let userManager = UserManager.shared
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Computed Properties
    var currentCompanyId: String? {
        userManager.currentCompany?.id
    }

    var isBoss: Bool {
        userManager.currentRole == .boss
    }

    var currentCompany: Company? {
        userManager.currentCompany
    }

    // MARK: - Employee Management

    /// 載入員工列表
    func loadEmployees() async {
        guard isBoss else {
            error = .permissionDenied
            return
        }

        isLoading = true
        error = nil

        do {
            let loadedEmployees = try await firebaseService.getCompanyEmployees()
            employees = loadedEmployees
            updateCompanyStats()

        } catch {
            self.error = CompanyError.from(error)
        }

        isLoading = false
    }

    /// 更新員工資料
    func updateEmployee(_ employee: User, newData: EmployeeUpdateData) async {
        guard isBoss else {
            error = .permissionDenied
            return
        }

        let employeeId = employee.id

        isLoading = true

        do {
            var updateData: [String: Any] = [:]

            if let name = newData.name {
                updateData["name"] = name
            }

            if let hourlyRate = newData.hourlyRate {
                updateData["hourly_rate"] = hourlyRate
            }

            if let employmentType = newData.employmentType {
                updateData["employment_type"] = employmentType.rawValue
            }

            if let isActive = newData.isActive {
                updateData["is_active"] = isActive
            }

            try await firebaseService.updateEmployee(employeeId: employeeId, updateData: updateData)

            // 更新本地資料
            if let index = employees.firstIndex(where: { $0.id == employeeId }) {
                var updatedEmployee = employee

                // 這裡需要創建新的 User 物件，因為 User 的屬性是 let
                // 實際上需要重新載入員工列表或者修改 User 結構
                await loadEmployees() // 簡單的方法：重新載入
            }

        } catch {
            self.error = CompanyError.from(error)
        }

        isLoading = false
    }

    /// 停用員工
    func deactivateEmployee(_ employee: User) async {
        guard isBoss else {
            error = .permissionDenied
            return
        }

        await updateEmployee(employee, newData: EmployeeUpdateData(isActive: false))
    }

    /// 啟用員工
    func activateEmployee(_ employee: User) async {
        guard isBoss else {
            error = .permissionDenied
            return
        }

        await updateEmployee(employee, newData: EmployeeUpdateData(isActive: true))
    }

    /// 更新員工時薪
    func updateEmployeeHourlyRate(_ employee: User, newRate: Double) async {
        await updateEmployee(employee, newData: EmployeeUpdateData(hourlyRate: newRate))
    }

    /// 更新員工類型 (正職/兼職)
    func updateEmploymentType(_ employee: User, newType: EmploymentType) async {
        await updateEmployee(employee, newData: EmployeeUpdateData(employmentType: newType))
    }

    // MARK: - Company Settings Management

    /// 重新生成邀請碼
    func regenerateInviteCode() async -> String? {
        guard let companyId = currentCompanyId, isBoss else {
            error = .permissionDenied
            return nil
        }

        isLoading = true

        do {
            let newInviteCode = generateInviteCode()

            let db = Firestore.firestore()
            try await db.collection("companies").document(companyId).updateData([
                "invite_code": newInviteCode,
                "updated_at": Timestamp()
            ])

            // 更新本地資料
            if let company = userManager.currentCompany {
                let updatedCompany = Company(
                    id: company.id,
                    name: company.name,
                    ownerId: company.ownerId,
                    inviteCode: newInviteCode,
                    maxEmployees: company.maxEmployees,
                    timezone: company.timezone,
                    createdAt: company.createdAt,
                    updatedAt: Timestamp()
                )
                userManager.currentCompany = updatedCompany
            }

            return newInviteCode

        } catch {
            self.error = CompanyError.from(error)
            return nil
        }

        isLoading = false
    }

    /// 更新公司基本設定
    func updateCompanySettings(name: String? = nil, maxEmployees: Int? = nil, timezone: String? = nil) async {
        guard let companyId = currentCompanyId, isBoss else {
            error = .permissionDenied
            return
        }

        isLoading = true

        do {
            var updateData: [String: Any] = ["updated_at": Timestamp()]

            if let name = name {
                updateData["name"] = name
            }

            if let maxEmployees = maxEmployees {
                updateData["max_employees"] = maxEmployees
            }

            if let timezone = timezone {
                updateData["timezone"] = timezone
            }

            let db = Firestore.firestore()
            try await db.collection("companies").document(companyId).updateData(updateData)

            // 重新載入公司資料
            await reloadCompanyData()

        } catch {
            self.error = CompanyError.from(error)
        }

        isLoading = false
    }

    /// 重新載入公司資料
    private func reloadCompanyData() async {
        guard let companyId = currentCompanyId else { return }

        do {
            let db = Firestore.firestore()
            let companyDoc = try await db.collection("companies").document(companyId).getDocument()

            if let companyData = companyDoc.data() {
                let company = try Company.from(data: companyData, id: companyId)
                userManager.currentCompany = company
            }
        } catch {
            print("重新載入公司資料失敗: \(error)")
        }
    }

    // MARK: - Statistics

    /// 更新公司統計資料
    private func updateCompanyStats() {
        let activeEmployees = employees.filter { $0.isActive }
        let fullTimeCount = activeEmployees.filter { $0.employmentType == "full_time" }.count
        let partTimeCount = activeEmployees.filter { $0.employmentType == "part_time" }.count

        companyStats = CompanyStats(
            totalEmployees: employees.count,
            activeEmployees: activeEmployees.count,
            fullTimeEmployees: fullTimeCount,
            partTimeEmployees: partTimeCount,
            averageHourlyRate: calculateAverageHourlyRate(activeEmployees)
        )
    }

    /// 計算平均時薪
    private func calculateAverageHourlyRate(_ employees: [User]) -> Double {
        let employeesWithRate = employees.filter { $0.hourlyRate > 0 }
        guard !employeesWithRate.isEmpty else { return 0 }

        let totalRate = employeesWithRate.reduce(0) { $0 + $1.hourlyRate }
        return totalRate / Double(employeesWithRate.count)
    }

    /// 獲取員工統計資料
    func getEmployeeStats() -> (active: Int, inactive: Int, fullTime: Int, partTime: Int) {
        let activeCount = employees.filter { $0.isActive }.count
        let inactiveCount = employees.count - activeCount
        let fullTimeCount = employees.filter { $0.employmentType == "full_time" }.count
        let partTimeCount = employees.filter { $0.employmentType == "part_time" }.count

        return (activeCount, inactiveCount, fullTimeCount, partTimeCount)
    }

    // MARK: - Company Information

    /// 獲取公司資訊摘要
    func getCompanySummary() -> CompanySummary? {
        guard let company = currentCompany else { return nil }

        let stats = getEmployeeStats()

        return CompanySummary(
            name: company.name,
            inviteCode: company.inviteCode,
            totalEmployees: employees.count,
            activeEmployees: stats.active,
            maxEmployees: company.maxEmployees,
            timezone: company.timezone,
            averageHourlyRate: companyStats.averageHourlyRate,
            createdAt: company.createdAt.dateValue()
        )
    }

    // MARK: - Helper Methods

    /// 生成邀請碼
    private func generateInviteCode() -> String {
        let chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in chars.randomElement()! })
    }

    /// 清除錯誤
    func clearError() {
        error = nil
    }

    /// 搜尋員工
    func searchEmployees(query: String) -> [User] {
        if query.isEmpty {
            return employees
        }

        return employees.filter { employee in
            employee.name.localizedCaseInsensitiveContains(query) ||
            employee.email.localizedCaseInsensitiveContains(query) ||
            employee.employeeId?.localizedCaseInsensitiveContains(query) == true
        }
    }

    /// 根據狀態過濾員工
    func filterEmployees(showActiveOnly: Bool) -> [User] {
        if showActiveOnly {
            return employees.filter { $0.isActive }
        }
        return employees
    }

    /// 根據類型過濾員工
    func filterEmployeesByType(_ type: EmploymentType?) -> [User] {
        guard let type = type else { return employees }
        return employees.filter { $0.employmentType == type.rawValue }
    }
}

// MARK: - Supporting Models

/// 公司摘要資訊
struct CompanySummary {
    let name: String
    let inviteCode: String
    let totalEmployees: Int
    let activeEmployees: Int
    let maxEmployees: Int
    let timezone: String
    let averageHourlyRate: Double
    let createdAt: Date

    var employeeUtilization: Double {
        guard maxEmployees > 0 else { return 0 }
        return Double(totalEmployees) / Double(maxEmployees)
    }

    var isNearCapacity: Bool {
        employeeUtilization >= 0.8
    }
}

// MARK: - Error Handling

enum CompanyError: Error, LocalizedError {
    case permissionDenied
    case invalidEmployeeData
    case employeeNotFound
    case companyNotFound
    case networkError
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "沒有權限執行此操作"
        case .invalidEmployeeData:
            return "員工資料格式錯誤"
        case .employeeNotFound:
            return "找不到指定員工"
        case .companyNotFound:
            return "找不到公司資料"
        case .networkError:
            return "網路連接錯誤"
        case .unknown(let message):
            return "發生錯誤：\(message)"
        }
    }

    static func from(_ error: Error) -> CompanyError {
        if let companyError = error as? CompanyError {
            return companyError
        }

        if let firebaseError = error as? FirebaseError {
            switch firebaseError {
            case .permissionDenied:
                return .permissionDenied
            case .userNotFound:
                return .employeeNotFound
            case .invalidCompany:
                return .companyNotFound
            case .networkError(let message):
                return .networkError
            default:
                return .unknown(firebaseError.localizedDescription)
            }
        }

        if let nsError = error as NSError? {
            switch nsError.domain {
            case "FIRFirestoreErrorDomain":
                switch nsError.code {
                case 7: // PERMISSION_DENIED
                    return .permissionDenied
                case 14: // UNAVAILABLE
                    return .networkError
                default:
                    return .unknown(nsError.localizedDescription)
                }
            default:
                return .unknown(nsError.localizedDescription)
            }
        }

        return .unknown(error.localizedDescription)
    }
}
