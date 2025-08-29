//
//  BossMainViewModel.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/8/26.
//

import SwiftUI
import Combine

// MARK: - Models
struct VacationSettings {
    var targetMonth: String = ""
    var targetYear: Int = Calendar.current.component(.year, from: Date())
    var maxDaysPerMonth: Int = 8
    var maxDaysPerWeek: Int = 2
    var limitType: VacationLimitType = .monthly
    var deadline: Date = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    var isPublished: Bool = false
    var publishedAt: Date?
}

struct EmployeeVacation: Identifiable {
    let id = UUID()
    let employeeName: String
    let employeeId: String
    let dates: Set<String>
    let submitDate: Date
    let status: VacationRequestStatus
    let note: String

    enum VacationRequestStatus {
        case pending
        case approved
        case rejected
    }
}

enum VacationLimitType: String, CaseIterable {
    case weekly = "週排休"
    case monthly = "月排休"

    var description: String {
        switch self {
        case .weekly:
            return "以週為單位限制排休天數"
        case .monthly:
            return "以月為單位限制排休天數"
        }
    }
}

// MARK: - BossMainViewModel
class BossMainViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var vacationSettings = VacationSettings()
    @Published var employeeVacations: [EmployeeVacation] = []
    @Published var isLoading = false
    @Published var showingToast = false
    @Published var toastMessage = ""
    @Published var toastType: ToastType = .success

    // Calendar interaction
    @Published var selectedDate: YearMonthDay?
    @Published var selectedDateVacations: [EmployeeVacation] = []

    // Computed Properties
    var isVacationPublished: Bool { vacationSettings.isPublished }
    var employeeVacationCount: Int { employeeVacations.count }

    // 按日期分組的排休資料
    var vacationsByDate: [YearMonthDay: [EmployeeVacation]] {
        var grouped: [YearMonthDay: [EmployeeVacation]] = [:]

        for vacation in employeeVacations {
            for dateString in vacation.dates {
                if let date = dateStringToYearMonthDay(dateString) {
                    if grouped[date] == nil {
                        grouped[date] = []
                    }
                    grouped[date]?.append(vacation)
                }
            }
        }

        return grouped
    }

    enum ToastType {
        case success
        case error
        case info

        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error: return "xmark.circle.fill"
            case .info: return "info.circle.fill"
            }
        }

        var color: Color {
            switch self {
            case .success: return .green
            case .error: return .red
            case .info: return .blue
            }
        }
    }

    init() {
        loadMockData()
    }

    // MARK: - Public Methods

    /// 發佈排休設定
    func publishVacationSettings(_ settings: VacationSettings) {
        isLoading = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.vacationSettings = settings
            self.vacationSettings.isPublished = true
            self.vacationSettings.publishedAt = Date()

            self.isLoading = false
            self.showToast(message: "排休已發佈！員工現在可以申請 \(settings.targetYear) 年 \(settings.targetMonth) 月的排休", type: .success)
        }
    }

    /// 取消發佈排休
    func unpublishVacation() {
        isLoading = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.vacationSettings.isPublished = false
            self.vacationSettings.publishedAt = nil

            self.isLoading = false
            self.showToast(message: "排休發佈已取消", type: .info)
        }
    }

    /// 選擇日期，顯示該日的排休詳情
    func selectDate(_ date: YearMonthDay) {
        if selectedDate == date {
            selectedDate = nil
            selectedDateVacations = []
        } else {
            selectedDate = date
            selectedDateVacations = vacationsByDate[date] ?? []
        }
    }

    /// 核准員工排休
    func approveVacation(_ vacationId: UUID) {
        if let index = employeeVacations.firstIndex(where: { $0.id == vacationId }) {
            // 創建更新後的排休申請
            let updatedVacation = EmployeeVacation(
                employeeName: employeeVacations[index].employeeName,
                employeeId: employeeVacations[index].employeeId,
                dates: employeeVacations[index].dates,
                submitDate: employeeVacations[index].submitDate,
                status: .approved,
                note: employeeVacations[index].note
            )
            employeeVacations[index] = updatedVacation

            // 更新選中日期的資料
            if let selectedDate = selectedDate {
                selectedDateVacations = vacationsByDate[selectedDate] ?? []
            }

            showToast(message: "已核准 \(updatedVacation.employeeName) 的排休申請", type: .success)
        }
    }

    /// 拒絕員工排休
    func rejectVacation(_ vacationId: UUID) {
        if let index = employeeVacations.firstIndex(where: { $0.id == vacationId }) {
            let updatedVacation = EmployeeVacation(
                employeeName: employeeVacations[index].employeeName,
                employeeId: employeeVacations[index].employeeId,
                dates: employeeVacations[index].dates,
                submitDate: employeeVacations[index].submitDate,
                status: .rejected,
                note: employeeVacations[index].note
            )
            employeeVacations[index] = updatedVacation

            if let selectedDate = selectedDate {
                selectedDateVacations = vacationsByDate[selectedDate] ?? []
            }

            showToast(message: "已拒絕 \(updatedVacation.employeeName) 的排休申請", type: .error)
        }
    }

    /// 獲取當月統計資訊
    func getMonthlyStats(for year: Int, month: Int) -> (totalEmployees: Int, totalDays: Int, pendingRequests: Int) {
        let monthString = String(format: "%04d-%02d", year, month)

        var totalEmployees = Set<String>()
        var totalDays = 0
        var pendingRequests = 0

        for vacation in employeeVacations {
            let matchingDates = vacation.dates.filter { $0.hasPrefix(monthString) }
            if !matchingDates.isEmpty {
                totalEmployees.insert(vacation.employeeId)
                totalDays += matchingDates.count

                if vacation.status == .pending {
                    pendingRequests += 1
                }
            }
        }

        return (totalEmployees.count, totalDays, pendingRequests)
    }

    // MARK: - Private Methods

    private func showToast(message: String, type: ToastType) {
        toastMessage = message
        toastType = type
        showingToast = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.showingToast = false
        }
    }

    private func dateStringToYearMonthDay(_ dateString: String) -> YearMonthDay? {
        let components = dateString.split(separator: "-")
        guard components.count == 3,
              let year = Int(components[0]),
              let month = Int(components[1]),
              let day = Int(components[2]) else {
            return nil
        }

        return YearMonthDay(year: year, month: month, day: day)
    }

    private func loadMockData() {
        // 獲取當前月份來設定假資料
        let now = Date()
        let currentYear = Calendar.current.component(.year, from: now)
        let currentMonth = Calendar.current.component(.month, from: now)

        // 確保假資料會顯示，先設定排休已發佈
        vacationSettings.isPublished = true
        vacationSettings.publishedAt = Date()

        // 模擬已有的員工排休申請 - 使用當前月份
        let mockVacations = [
            EmployeeVacation(
                employeeName: "王小明",
                employeeId: "E001",
                dates: Set([
                    String(format: "%04d-%02d-15", currentYear, currentMonth),
                    String(format: "%04d-%02d-16", currentYear, currentMonth)
                ]),
                submitDate: Date(),
                status: .pending,
                note: "家庭旅遊"
            ),
            EmployeeVacation(
                employeeName: "李美麗",
                employeeId: "E002",
                dates: Set([
                    String(format: "%04d-%02d-20", currentYear, currentMonth),
                    String(format: "%04d-%02d-21", currentYear, currentMonth),
                    String(format: "%04d-%02d-22", currentYear, currentMonth)
                ]),
                submitDate: Date(),
                status: .approved,
                note: "出國度假"
            ),
            EmployeeVacation(
                employeeName: "陳大華",
                employeeId: "E003",
                dates: Set([String(format: "%04d-%02d-10", currentYear, currentMonth)]),
                submitDate: Date(),
                status: .pending,
                note: "醫療預約"
            ),
            EmployeeVacation(
                employeeName: "張小花",
                employeeId: "E004",
                dates: Set([
                    String(format: "%04d-%02d-25", currentYear, currentMonth),
                    String(format: "%04d-%02d-26", currentYear, currentMonth)
                ]),
                submitDate: Date(),
                status: .approved,
                note: "家人生日"
            )
        ]

        employeeVacations = mockVacations

        // Debug print to verify data loading
        print("✅ Mock data loaded:")
        for vacation in employeeVacations {
            print("- \(vacation.employeeName): \(vacation.dates)")
        }
    }
}
