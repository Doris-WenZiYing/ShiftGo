//
//  NotificationModels.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/9/18.
//

import Foundation

struct NotificationSettings: Codable {
    var enablePushNotifications: Bool = true
    var enableEmailNotifications: Bool = true
    var notifyOnRequestSubmitted: Bool = true
    var notifyOnRequestReviewed: Bool = true
    var notifyOnDeadlineApproaching: Bool = true
    var notifyOnSchedulePublished: Bool = true
    var reminderDaysBefore: Int = 1
    var quietHoursStart: String = "22:00"
    var quietHoursEnd: String = "08:00"
    var weekendNotifications: Bool = false

    static func from(_ data: [String: Any]) -> NotificationSettings {
        return NotificationSettings(
            enablePushNotifications: data["enable_push_notifications"] as? Bool ?? true,
            enableEmailNotifications: data["enable_email_notifications"] as? Bool ?? true,
            notifyOnRequestSubmitted: data["notify_on_request_submitted"] as? Bool ?? true,
            notifyOnRequestReviewed: data["notify_on_request_reviewed"] as? Bool ?? true,
            notifyOnDeadlineApproaching: data["notify_on_deadline_approaching"] as? Bool ?? true,
            notifyOnSchedulePublished: data["notify_on_schedule_published"] as? Bool ?? true,
            reminderDaysBefore: data["reminder_days_before"] as? Int ?? 1,
            quietHoursStart: data["quiet_hours_start"] as? String ?? "22:00",
            quietHoursEnd: data["quiet_hours_end"] as? String ?? "08:00",
            weekendNotifications: data["weekend_notifications"] as? Bool ?? false
        )
    }

    func toDictionary() -> [String: Any] {
        return [
            "enable_push_notifications": enablePushNotifications,
            "enable_email_notifications": enableEmailNotifications,
            "notify_on_request_submitted": notifyOnRequestSubmitted,
            "notify_on_request_reviewed": notifyOnRequestReviewed,
            "notify_on_deadline_approaching": notifyOnDeadlineApproaching,
            "notify_on_schedule_published": notifyOnSchedulePublished,
            "reminder_days_before": reminderDaysBefore,
            "quiet_hours_start": quietHoursStart,
            "quiet_hours_end": quietHoursEnd,
            "weekend_notifications": weekendNotifications
        ]
    }
}
