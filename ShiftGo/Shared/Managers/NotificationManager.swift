//
//  NotificationManager.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/9/13.
//

import Foundation
import UserNotifications
import SwiftUI

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var hasPermission = false
    @Published var notificationSettings = NotificationSettings()

    private init() {
        checkNotificationStatus()
    }

    // MARK: - Permission Management

    func requestPermission() async {
        let center = UNUserNotificationCenter.current()

        do {
            let granted = try await center.requestAuthorization(
                options: [.alert, .sound, .badge]
            )

            await MainActor.run {
                hasPermission = granted
            }

            if granted {
                print("✅ 通知權限已獲得")
            } else {
                print("❌ 通知權限被拒絕")
            }
        } catch {
            print("❌ 請求通知權限失敗: \(error)")
        }
    }

    private func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.hasPermission = settings.authorizationStatus == .authorized
            }
        }
    }

    // MARK: - Vacation Notifications

    /// 排休狀態更新通知
    func sendVacationStatusUpdate(
        employeeName: String,
        status: EmployeeVacation.VacationRequestStatus,
        dates: [String]
    ) {
        guard hasPermission else { return }

        let content = UNMutableNotificationContent()
        content.title = "排休申請更新"

        switch status {
        case .approved:
            content.body = "您的排休申請已核准 ✅"
            content.sound = .default
        case .rejected:
            content.body = "您的排休申請已被拒絕 ❌"
            content.sound = .default
        case .pending:
            content.body = "您的排休申請正在審核中 ⏳"
        }

        content.subtitle = "日期：\(dates.joined(separator: ", "))"
        content.badge = 1

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "vacation_status_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ 發送通知失敗: \(error)")
            } else {
                print("✅ 排休狀態通知已發送")
            }
        }
    }

    /// 排休申請提醒 (給老闆)
    func notifyBossOfNewRequest(
        employeeName: String,
        dates: [String]
    ) {
        guard hasPermission else { return }

        let content = UNMutableNotificationContent()
        content.title = "新的排休申請"
        content.body = "\(employeeName) 申請了排休"
        content.subtitle = "日期：\(dates.joined(separator: ", "))"
        content.sound = .default
        content.badge = 1

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "new_request_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Schedule Reminders

    /// 排休截止提醒
    func scheduleDeadlineReminder(for deadline: Date, monthYear: String) {
        guard hasPermission else { return }

        let calendar = Calendar.current
        let reminderDate = calendar.date(byAdding: .day, value: -1, to: deadline)!

        guard reminderDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "排休截止提醒"
        content.body = "\(monthYear) 排休申請將於明天截止"
        content.subtitle = "請盡快提交您的排休申請"
        content.sound = .default

        let triggerDate = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let request = UNNotificationRequest(
            identifier: "deadline_reminder_\(monthYear)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ 設置截止提醒失敗: \(error)")
            } else {
                print("✅ 截止提醒已設置: \(deadline)")
            }
        }
    }

    /// 班表發布通知
    func notifySchedulePublished(monthYear: String) {
        guard hasPermission else { return }

        let content = UNMutableNotificationContent()
        content.title = "新班表發布"
        content.body = "\(monthYear) 工作班表已發布"
        content.subtitle = "點擊查看您的工作安排"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(
            identifier: "schedule_published_\(monthYear)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Settings Management

    func updateNotificationSettings(_ settings: NotificationSettings) {
        notificationSettings = settings

        // 保存到 UserDefaults
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(settings) {
            UserDefaults.standard.set(data, forKey: "notification_settings")
        }
    }

    func loadNotificationSettings() {
        guard let data = UserDefaults.standard.data(forKey: "notification_settings"),
              let settings = try? JSONDecoder().decode(NotificationSettings.self, from: data) else {
            return
        }

        notificationSettings = settings
    }

    // MARK: - Clear Notifications

    func clearAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}
