//
//  BossMainViewModel.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/8/26.
//

import SwiftUI
import Combine

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

    // Firebase service
    private let firebaseService = FirebaseService.shared

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
        // 載入當前月份資料
        let now = Date()
        let currentYear = Calendar.current.component(.year, from: now)
        let currentMonth = Calendar.current.component(.month, from: now)

        Task {
            await loadData(for: currentYear, month: currentMonth)
        }
    }

    // MARK: - Public Methods

    /// 載入特定月份的資料
    @MainActor
    func loadData(for year: Int, month: Int) {
        Task {
            await loadVacationData(year: year, month: month)
        }
    }

    /// 發佈排休設定 (修復版)
    @MainActor
    func publishVacationSettings(_ settings: VacationSettings) {
        print("🎯 [Boss] Starting to publish vacation settings")
        print("   - Original settings isPublished: \(settings.isPublished)")

        isLoading = true

        Task {
            do {
                // 🔥 關鍵修復：確保設置為已發布狀態
                var publishedSettings = settings
                publishedSettings.isPublished = true
                publishedSettings.publishedAt = Date()

                print("🔄 [Boss] Modified settings for publishing:")
                print("   - isPublished: \(publishedSettings.isPublished)")
                print("   - publishedAt: \(publishedSettings.publishedAt?.description ?? "nil")")

                try await firebaseService.publishVacationSettings(publishedSettings)

                await MainActor.run {
                    // 更新本地狀態
                    vacationSettings = publishedSettings
                    isLoading = false
                    showToast(message: "排休已發佈！員工現在可以申請 \(publishedSettings.targetYear) 年 \(publishedSettings.targetMonth) 的排休", type: .success)
                }

                // 立即重新載入資料確認狀態
                let monthNumber = getMonthNumber(from: publishedSettings.targetMonth)
                await loadVacationData(year: publishedSettings.targetYear, month: monthNumber)

            } catch {
                print("❌ [Boss] Publish failed: \(error)")
                await MainActor.run {
                    isLoading = false
                    showToast(message: "發佈失敗：\(error.localizedDescription)", type: .error)
                }
            }
        }
    }

    /// 取消發佈排休
    @MainActor
    func unpublishVacation() {
        print("🚫 [Boss] Starting to unpublish vacation")
        isLoading = true

        Task {
            do {
                let currentYear = vacationSettings.targetYear
                let monthNumber = getMonthNumber(from: vacationSettings.targetMonth)

                try await firebaseService.unpublishVacationSettings(year: currentYear, month: monthNumber)

                await MainActor.run {
                    vacationSettings.isPublished = false
                    vacationSettings.publishedAt = nil
                    isLoading = false
                    showToast(message: "排休發佈已取消", type: .info)
                }

                // 重新載入資料確認狀態
                await loadVacationData(year: currentYear, month: monthNumber)

            } catch {
                print("❌ [Boss] Unpublish failed: \(error)")
                await MainActor.run {
                    isLoading = false
                    showToast(message: "取消發佈失敗：\(error.localizedDescription)", type: .error)
                }
            }
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
    @MainActor
    func approveVacation(_ vacationId: UUID) {
        if let index = employeeVacations.firstIndex(where: { $0.id == vacationId }) {
            let vacation = employeeVacations[index]

            Task {
                do {
                    // 從日期字串中獲取年月
                    if let firstDate = vacation.dates.first,
                       let (year, month) = getYearMonthFromDateString(firstDate) {

                        try await firebaseService.updateVacationRequestStatus(
                            employeeId: vacation.employeeId,
                            year: year,
                            month: month,
                            status: .approved
                        )

                        await MainActor.run {
                            // 更新本地資料
                            let updatedVacation = EmployeeVacation(
                                employeeName: vacation.employeeName,
                                employeeId: vacation.employeeId,
                                dates: vacation.dates,
                                submitDate: vacation.submitDate,
                                status: .approved,
                                note: vacation.note
                            )
                            employeeVacations[index] = updatedVacation

                            // 更新選中日期的資料
                            if let selectedDate = selectedDate {
                                selectedDateVacations = vacationsByDate[selectedDate] ?? []
                            }

                            showToast(message: "已核准 \(vacation.employeeName) 的排休申請", type: .success)
                        }
                    }
                } catch {
                    await MainActor.run {
                        showToast(message: "核准失敗：\(error.localizedDescription)", type: .error)
                    }
                }
            }
        }
    }

    /// 拒絕員工排休
    @MainActor
    func rejectVacation(_ vacationId: UUID) {
        if let index = employeeVacations.firstIndex(where: { $0.id == vacationId }) {
            let vacation = employeeVacations[index]

            Task {
                do {
                    // 從日期字串中獲取年月
                    if let firstDate = vacation.dates.first,
                       let (year, month) = getYearMonthFromDateString(firstDate) {

                        try await firebaseService.updateVacationRequestStatus(
                            employeeId: vacation.employeeId,
                            year: year,
                            month: month,
                            status: .rejected
                        )

                        await MainActor.run {
                            // 更新本地資料
                            let updatedVacation = EmployeeVacation(
                                employeeName: vacation.employeeName,
                                employeeId: vacation.employeeId,
                                dates: vacation.dates,
                                submitDate: vacation.submitDate,
                                status: .rejected,
                                note: vacation.note
                            )
                            employeeVacations[index] = updatedVacation

                            // 更新選中日期的資料
                            if let selectedDate = selectedDate {
                                selectedDateVacations = vacationsByDate[selectedDate] ?? []
                            }

                            showToast(message: "已拒絕 \(vacation.employeeName) 的排休申請", type: .error)
                        }
                    }
                } catch {
                    await MainActor.run {
                        showToast(message: "拒絕失敗：\(error.localizedDescription)", type: .error)
                    }
                }
            }
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

    /// 載入排休相關資料
    private func loadVacationData(year: Int, month: Int) async {
        await MainActor.run {
            isLoading = true
        }

        async let settingsTask: () = loadVacationSettings(year: year, month: month)
        async let requestsTask: () = loadVacationRequests(year: year, month: month)

        await settingsTask
        await requestsTask

        await MainActor.run {
            isLoading = false
            print("✅ [Boss] Data loaded - Published: \(vacationSettings.isPublished)")
        }
    }

    /// 載入排休設定
    private func loadVacationSettings(year: Int, month: Int) async {
        do {
            if let settings = try await firebaseService.getVacationSettings(year: year, month: month) {
                await MainActor.run {
                    vacationSettings = settings
                    print("✅ [Boss] Loaded settings - isPublished: \(settings.isPublished)")
                }
            } else {
                await MainActor.run {
                    vacationSettings = VacationSettings.defaultSettings(for: year, month: month)
                    print("⚠️ [Boss] No settings found, using defaults")
                }
            }
        } catch {
            await MainActor.run {
                vacationSettings = VacationSettings.defaultSettings(for: year, month: month)
                print("❌ [Boss] Failed to load vacation settings: \(error)")
            }
        }
    }

    /// 載入排休申請
    private func loadVacationRequests(year: Int, month: Int) async {
        do {
            let requests = try await firebaseService.getVacationRequests(year: year, month: month)
            await MainActor.run {
                employeeVacations = requests
                print("✅ [Boss] Loaded \(requests.count) vacation requests")
            }
        } catch {
            await MainActor.run {
                employeeVacations = []
                print("❌ [Boss] Failed to load vacation requests: \(error)")
            }
        }
    }

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

    private func getYearMonthFromDateString(_ dateString: String) -> (year: Int, month: Int)? {
        let components = dateString.split(separator: "-")
        guard components.count == 3,
              let year = Int(components[0]),
              let month = Int(components[1]) else {
            return nil
        }
        return (year, month)
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
