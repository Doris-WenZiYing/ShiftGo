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

    // Mock employee data (在實際應用中應該來自 Firebase Auth)
    private let employeeName = "王小明"
    private let employeeId = "E001"

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

        print("🎯 [Employee] Submitting vacation request for \(year)/\(month) with \(selectedVacationDates.count) dates")

        isLoading = true

        Task {
            do {
                try await firebaseService.submitVacationRequest(
                    employeeName: employeeName,
                    employeeId: employeeId,
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
        let stats = getVacationStats(for: date.year, month: date.month)

        // 如果已經選擇，可以取消選擇
        if selectedVacationDates.contains(date) {
            return true
        }

        // 檢查月限制
        if selectedVacationDates.count >= stats.maxDays {
            return false
        }

        return true
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
            showToast(message: "超過月排休上限", type: .error)
        }
    }

    /// 清除所有選擇的日期
    func clearSelectedDates() {
        print("🗑️ [Employee] Cleared all selected dates")
        selectedVacationDates.removeAll()
    }

    // MARK: - Private Methods

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
