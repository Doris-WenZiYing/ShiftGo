//
//  TimeTrackerViewModel.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/9/13.
//

import Foundation
import SwiftUI

// MARK: - 出勤狀態枚舉
enum AttendanceStatus {
    case normal
    case late
    case overtime
    case leave
    case absent

    var displayText: String {
        switch self {
        case .normal: return "正常"
        case .late: return "遲到"
        case .overtime: return "加班"
        case .leave: return "請假"
        case .absent: return "缺勤"
        }
    }

    var color: Color {
        switch self {
        case .normal: return .green
        case .late: return .orange
        case .overtime: return .blue
        case .leave: return .gray
        case .absent: return .red
        }
    }
}

// MARK: - 週統計資料
struct WeeklyData {
    let day: String
    let hours: Int
}

// MARK: - 時間記錄
struct TimeRecord: Identifiable {
    let id = UUID()
    let dateString: String
    let clockIn: String
    let clockOut: String?
    let totalHours: Int
    let status: AttendanceStatus

    init(dateString: String, clockIn: String, clockOut: String?, totalHours: Int, status: AttendanceStatus) {
        self.dateString = dateString
        self.clockIn = clockIn
        self.clockOut = clockOut
        self.totalHours = totalHours
        self.status = status
    }
}

// MARK: - ViewModel
class TimeTrackerViewModel: ObservableObject {
    @Published var isWorking = false
    @Published var currentTime = ""
    @Published var todayWorkStart: Date?
    @Published var currentWorkDuration = "00:00:00"
    @Published var todayTotalHours = "0小時"
    @Published var todayBreakTime = "0分鐘"
    @Published var todayOvertimeHours = "0小時"
    @Published var weeklyData: [WeeklyData] = []
    @Published var recentRecords: [TimeRecord] = []

    private var timer: Timer?

    init() {
        startTimer()
        generateMockData()
    }

    func loadTodayStatus() {
        // 載入今日工作狀態
        print("載入今日工作狀態")
    }

    func clockIn() {
        print("上班打卡")
        isWorking = true
        todayWorkStart = Date()
        // 實際實現打卡邏輯
    }

    func clockOut() {
        print("下班打卡")
        isWorking = false
        todayWorkStart = nil
        // 實際實現下班打卡邏輯
        calculateTodayHours()
    }

    func startBreak() {
        print("開始休息")
        // 開始休息邏輯
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.updateCurrentTime()
            self.updateWorkDuration()
        }
    }

    private func updateCurrentTime() {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.locale = Locale(identifier: "zh_TW")
        currentTime = formatter.string(from: Date())
    }

    private func updateWorkDuration() {
        guard let startTime = todayWorkStart, isWorking else { return }

        let duration = Date().timeIntervalSince(startTime)
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        let seconds = Int(duration) % 60

        currentWorkDuration = String(format: "%02d:%02d:%02d", hours, minutes, seconds)

        // 更新今日總工時
        if duration >= 3600 {
            todayTotalHours = String(format: "%.1f小時", duration / 3600)
        } else {
            todayTotalHours = String(format: "%d分鐘", Int(duration / 60))
        }
    }

    private func calculateTodayHours() {
        // 計算今日工作時數
        todayTotalHours = "8.5小時"
        todayBreakTime = "60分鐘"
        todayOvertimeHours = "1.5小時"
    }

    private func generateMockData() {
        weeklyData = [
            WeeklyData(day: "一", hours: 8),
            WeeklyData(day: "二", hours: 9),
            WeeklyData(day: "三", hours: 7),
            WeeklyData(day: "四", hours: 8),
            WeeklyData(day: "五", hours: 10),
            WeeklyData(day: "六", hours: 6),
            WeeklyData(day: "日", hours: 0)
        ]

        recentRecords = [
            TimeRecord(
                dateString: "2025/09/13",
                clockIn: "09:00",
                clockOut: "18:00",
                totalHours: 8,
                status: AttendanceStatus.normal
            ),
            TimeRecord(
                dateString: "2025/09/12",
                clockIn: "09:15",
                clockOut: "18:00",
                totalHours: 8,
                status: AttendanceStatus.late
            ),
            TimeRecord(
                dateString: "2025/09/11",
                clockIn: "09:00",
                clockOut: "19:00",
                totalHours: 9,
                status: AttendanceStatus.overtime
            ),
            TimeRecord(
                dateString: "2025/09/10",
                clockIn: "09:00",
                clockOut: "18:00",
                totalHours: 8,
                status: AttendanceStatus.normal
            ),
            TimeRecord(
                dateString: "2025/09/09",
                clockIn: "-",
                clockOut: nil,
                totalHours: 0,
                status: AttendanceStatus.leave
            )
        ]
    }

    deinit {
        timer?.invalidate()
    }
}
