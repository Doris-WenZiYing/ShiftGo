//
//  EmployeeMainViewModel.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/8/30.
//

import SwiftUI
import Combine

class EmployeeMainViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var myVacationRequests: [EmployeeVacation] = []
    @Published var vacationSettings: VacationSettings?
    @Published var isVacationPublished: Bool = false
    @Published var selectedVacationDates: Set<YearMonthDay> = []
    @Published var isLoading = false
    @Published var showingToast = false
    @Published var toastMessage = ""
    @Published var toastType: ToastType = .success

    // Form data for vacation request
    @Published var vacationNote: String = ""

    private let firebaseService = FirebaseService.shared
    private let userManager = UserManager.shared

    // MARK: - Public Methods

    /// 載入特定月份的資料
    @MainActor
    func loadData(for year: Int, month: Int) {
        print("🔵 [Employee] Loading data for \(year)/\(month)")
        Task {
            await loadVacationData(year: year, month: month)
        }
    }

    /// 手動刷新資料
    @MainActor
    func refreshData(for year: Int, month: Int) async {
        print("🔄 [Employee] Manual refresh for \(year)/\(month)")
        await loadVacationData(year: year, month: month)
    }

    /// 提交排休申請
    @MainActor
    func submitVacationRequest(for year: Int, month: Int) {
        guard !selectedVacationDates.isEmpty else {
            showToast(message: "請選擇排休日期", type: .error)
            return
        }

        // 🔥 新增：提交前最終驗證
        if let validator = validator {
            let result = validator.validate(selectedDates: selectedVacationDates, targetYear: year, targetMonth: month)
            if !result.isValid, let errorMessage = result.errorMessage {
                showToast(message: errorMessage, type: .error)
                return
            }
        }

        print("🎯 [Employee] Submitting vacation request for \(year)/\(month) with \(selectedVacationDates.count) dates")

        isLoading = true

        guard let currentUser = userManager.currentUser else {
            showToast(message: "使用者未登入，請重新登入", type: .error)
            return
        }

        Task {
            do {
                try await firebaseService.submitVacationRequest(
                    employeeName: currentUser.name,
                    employeeId: currentUser.employeeId ?? "no employee id",
                    year: year,
                    month: month,
                    vacationDates: selectedVacationDates,
                    note: vacationNote
                )

                await MainActor.run {
                    selectedVacationDates.removeAll()
                    vacationNote = ""
                    isLoading = false
                    showToast(message: "排休申請已提交，等待主管審核", type: .success)
                }

                // 重新載入資料
                await loadMyVacationRequests(year: year, month: month)

            } catch {
                print("❌ [Employee] Submit failed: \(error)")
                await MainActor.run {
                    isLoading = false
                    showToast(message: "提交失敗：\(error.localizedDescription)", type: .error)
                }
            }
        }
    }

    /// 檢查是否可以申請排休
    func canSubmitVacation(for year: Int, month: Int) -> Bool {
        let canSubmit = isVacationPublished &&
        !hasExistingRequest(for: year, month: month) &&
        !selectedVacationDates.isEmpty

        print("🔍 [Employee] Can submit vacation: \(canSubmit) (published: \(isVacationPublished), hasRequest: \(hasExistingRequest(for: year, month: month)), selectedDates: \(selectedVacationDates.count))")

        return canSubmit
    }

    /// 檢查是否已有該月份的申請
    func hasExistingRequest(for year: Int, month: Int) -> Bool {
        let hasRequest = myVacationRequests.contains { vacation in
            vacation.dates.contains { dateString in
                let components = dateString.split(separator: "-")
                guard components.count == 3,
                      let requestYear = Int(components[0]),
                      let requestMonth = Int(components[1]) else {
                    return false
                }
                return requestYear == year && requestMonth == month
            }
        }

        if hasRequest {
            print("✅ [Employee] Found existing request for \(year)/\(month)")
        }

        return hasRequest
    }

    func getDetailedVacationStats(for year: Int, month: Int) -> VacationStats? {
            guard let settings = vacationSettings else { return nil }

            return VacationStatsHelper.getStats(
                selectedDates: selectedVacationDates,
                settings: settings,
                targetYear: year,
                targetMonth: month
            )
        }

    /// 獲取當前月份的申請狀態
    func getVacationStatus(for year: Int, month: Int) -> EmployeeVacationStatus {
        if !isVacationPublished {
            print("🔍 [Employee] Status: Not published")
            return .notSubmitted
        }

        // 檢查是否有該月份的申請
        let monthlyRequests = myVacationRequests.filter { vacation in
            vacation.dates.contains { dateString in
                let components = dateString.split(separator: "-")
                guard components.count == 3,
                      let requestYear = Int(components[0]),
                      let requestMonth = Int(components[1]) else {
                    return false
                }
                return requestYear == year && requestMonth == month
            }
        }

        if let request = monthlyRequests.first {
            print("🔍 [Employee] Status: \(request.status)")
            switch request.status {
            case .pending:
                return .pending
            case .approved:
                return .approved
            case .rejected:
                return .rejected
            }
        }

        print("🔍 [Employee] Status: Not submitted")
        return .notSubmitted
    }

    /// 獲取排休統計
    func getVacationStats(for year: Int, month: Int) -> (selectedDays: Int, maxDays: Int, maxWeeklyDays: Int) {
        let selectedDays = selectedVacationDates.count
        let maxDays = vacationSettings?.maxDaysPerMonth ?? 8
        let maxWeeklyDays = vacationSettings?.maxDaysPerWeek ?? 2

        return (selectedDays, maxDays, maxWeeklyDays)
    }

    /// 檢查是否可以選擇該日期
    func canSelectDate(_ date: YearMonthDay) -> Bool {
        guard let validator = validator else {
            let stats = getVacationStats(for: date.year, month: date.month)
            if selectedVacationDates.contains(date) {
                return true
            }
            return selectedVacationDates.count < stats.maxDays
        }

        return validator.canSelectDate(date, currentSelection: selectedVacationDates)
    }

    /// 切換日期選擇
    func toggleDateSelection(_ date: YearMonthDay) {
        if selectedVacationDates.contains(date) {
            selectedVacationDates.remove(date)
            print("🗑️ [Employee] Removed date: \(date.year)-\(date.month)-\(date.day)")
        } else if canSelectDate(date) {
            selectedVacationDates.insert(date)
            print("✅ [Employee] Added date: \(date.year)-\(date.month)-\(date.day)")
        } else {
            // 🔥 新增：顯示具體的驗證錯誤
            if let validator = validator {
                let newSelection = selectedVacationDates.union([date])
                let result = validator.validate(selectedDates: newSelection, targetYear: date.year, targetMonth: date.month)

                if let errorMessage = result.errorMessage {
                    showToast(message: errorMessage, type: .error)
                } else {
                    showToast(message: "無法選擇此日期", type: .error)
                }
            } else {
                showToast(message: "超過排休上限", type: .error)
            }
        }
    }

    func selectWeekends(for year: Int, month: Int) {
        guard let settings = vacationSettings else { return }

        let calendar = Calendar.current
        guard let date = calendar.date(from: DateComponents(year: year, month: month, day: 1)),
              let range = calendar.range(of: .day, in: .month, for: date) else {
            return
        }

        var weekendDates: Set<YearMonthDay> = []

        for day in 1...range.count {
            let currentDate = calendar.date(from: DateComponents(year: year, month: month, day: day))!
            let weekday = calendar.component(.weekday, from: currentDate)

            if weekday == 1 || weekday == 7 { // Sunday or Saturday
                let yearMonthDay = YearMonthDay(year: year, month: month, day: day)
                weekendDates.insert(yearMonthDay)
            }
        }

        // 使用驗證器檢查是否可以選擇這些日期
        if let validator = validator {
            let result = validator.validate(selectedDates: weekendDates, targetYear: year, targetMonth: month)
            if result.isValid {
                selectedVacationDates = weekendDates
                showToast(message: "已選擇所有週末 (\(weekendDates.count) 天)", type: .success)
            } else if let errorMessage = result.errorMessage {
                showToast(message: errorMessage, type: .error)
            }
        } else {
            selectedVacationDates = weekendDates
            showToast(message: "已選擇所有週末 (\(weekendDates.count) 天)", type: .success)
        }
    }

    func getDateSuggestions(for year: Int, month: Int) -> [YearMonthDay] {
            guard let validator = validator else { return [] }

            let calendar = Calendar.current
            guard let date = calendar.date(from: DateComponents(year: year, month: month, day: 1)),
                  let range = calendar.range(of: .day, in: .month, for: date) else {
                return []
            }

            var suggestions: [YearMonthDay] = []

            for day in 1...range.count {
                let yearMonthDay = YearMonthDay(year: year, month: month, day: day)
                if validator.canSelectDate(yearMonthDay, currentSelection: selectedVacationDates) {
                    suggestions.append(yearMonthDay)
                }
            }

            return suggestions
        }

    /// 清除所有選擇的日期
    func clearSelectedDates() {
        print("🗑️ [Employee] Cleared all selected dates")
        selectedVacationDates.removeAll()
    }

    // MARK: - Private Methods

    private var validator: VacationValidator? {
        guard let settings = vacationSettings else { return nil }
        return VacationValidator(settings: settings)
    }

    /// 載入排休相關資料
    private func loadVacationData(year: Int, month: Int) async {
        await MainActor.run {
            isLoading = true
        }

        print("🔄 [Employee] Starting to load vacation data for \(year)/\(month)")

        async let settingsTask: () = loadVacationSettings(year: year, month: month)
        async let requestsTask: () = loadMyVacationRequests(year: year, month: month)
        async let publishedTask: () = checkVacationPublished(year: year, month: month)

        await settingsTask
        await requestsTask
        await publishedTask

        await MainActor.run {
            isLoading = false
            print("✅ [Employee] Finished loading data. Published: \(isVacationPublished), Requests: \(myVacationRequests.count)")
        }
    }

    /// 載入排休設定
    private func loadVacationSettings(year: Int, month: Int) async {
        print("📋 [Employee] Loading vacation settings for \(year)/\(month)")
        do {
            let settings = try await firebaseService.getVacationSettings(year: year, month: month)
            await MainActor.run {
                vacationSettings = settings
                if let settings = settings {
                    print("✅ [Employee] Loaded settings: \(settings.targetYear)/\(getMonthNumber(from: settings.targetMonth)) (published: \(settings.isPublished))")
                } else {
                    print("⚠️ [Employee] No vacation settings found")
                }
            }
        } catch {
            await MainActor.run {
                vacationSettings = nil
                print("❌ [Employee] Failed to load vacation settings: \(error)")
            }
        }
    }

    /// 載入我的排休申請
    private func loadMyVacationRequests(year: Int, month: Int) async {
        print("📝 [Employee] Loading my vacation requests for \(year)/\(month)")
        do {
            let requests = try await firebaseService.getMyVacationRequests(year: year, month: month)
            await MainActor.run {
                myVacationRequests = requests
                print("✅ [Employee] Loaded \(requests.count) vacation requests")
                for request in requests {
                    print("   - \(request.employeeName): \(request.dates.joined(separator: ", ")) (\(request.status))")
                }
            }
        } catch {
            await MainActor.run {
                myVacationRequests = []
                print("❌ [Employee] Failed to load vacation requests: \(error)")
            }
        }
    }

    /// 檢查排休是否已發布
    private func checkVacationPublished(year: Int, month: Int) async {
        print("🔍 [Employee] Checking if vacation is published for \(year)/\(month)")
        do {
            let published = try await firebaseService.isVacationPublished(year: year, month: month)
            await MainActor.run {
                isVacationPublished = published
                print("✅ [Employee] Vacation published status: \(published)")
            }
        } catch {
            await MainActor.run {
                isVacationPublished = false
                print("❌ [Employee] Failed to check vacation published status: \(error)")
            }
        }
    }

    /// 顯示提示訊息
    private func showToast(message: String, type: ToastType) {
        toastMessage = message
        toastType = type
        showingToast = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.showingToast = false
        }
    }

    /// 月份字串轉數字
    private func getMonthNumber(from monthString: String) -> Int {
        let monthMap = [
            "1月": 1, "2月": 2, "3月": 3, "4月": 4,
            "5月": 5, "6月": 6, "7月": 7, "8月": 8,
            "9月": 9, "10月": 10, "11月": 11, "12月": 12
        ]
        return monthMap[monthString] ?? 1
    }
}
