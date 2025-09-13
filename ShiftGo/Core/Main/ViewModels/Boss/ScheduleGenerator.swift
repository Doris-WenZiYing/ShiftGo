//
//  ScheduleGenerator.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/9/13.
//

import Foundation
import SwiftUI

// MARK: - 班表模型
struct WorkSchedule: Identifiable {
    let id = UUID()
    let year: Int
    let month: Int
    let shifts: [DailyShift]
    let generatedAt: Date

    var totalWorkDays: Int {
        shifts.filter { !$0.assignments.isEmpty }.count
    }
}

struct DailyShift: Identifiable {
    let id = UUID()
    let date: YearMonthDay
    let assignments: [ShiftAssignment]
    let isHoliday: Bool

    var totalHours: Double {
        assignments.reduce(0) { $0 + $1.hours }
    }
}

struct ShiftAssignment: Identifiable {
    let id = UUID()
    let employeeId: String
    let employeeName: String
    let startTime: String
    let endTime: String
    let hours: Double
    let position: String
}

// MARK: - 班表生成器
class ScheduleGenerator: ObservableObject {
    @Published var currentSchedule: WorkSchedule?
    @Published var isGenerating = false

    /// 生成基礎班表
    func generateSchedule(
        year: Int,
        month: Int,
        employees: [User],
        vacations: [EmployeeVacation]
    ) -> WorkSchedule {
        print("🔄 開始生成 \(year)/\(month) 班表")

        let calendar = Calendar.current
        let startDate = calendar.date(from: DateComponents(year: year, month: month, day: 1))!
        let range = calendar.range(of: .day, in: .month, for: startDate)!

        var dailyShifts: [DailyShift] = []

        for day in 1...range.count {
            let date = YearMonthDay(year: year, month: month, day: day)
            let shift = generateDailyShift(for: date, employees: employees, vacations: vacations)
            dailyShifts.append(shift)
        }

        let schedule = WorkSchedule(
            year: year,
            month: month,
            shifts: dailyShifts,
            generatedAt: Date()
        )

        return schedule
    }

    /// 生成單日班表
    private func generateDailyShift(
        for date: YearMonthDay,
        employees: [User],
        vacations: [EmployeeVacation]
    ) -> DailyShift {

        let dateString = String(format: "%04d-%02d-%02d", date.year, date.month, date.day)
        let isWeekend = date.dayOfWeek == .sat || date.dayOfWeek == .sun

        // 找出當日休假的員工
        let onVacation = Set(vacations.compactMap { vacation in
            vacation.dates.contains(dateString) ? vacation.employeeId : nil
        })

        // 可工作的員工
        let availableEmployees = employees.filter { employee in
            employee.isActive && !onVacation.contains(employee.employeeId ?? "")
        }

        var assignments: [ShiftAssignment] = []

        // 簡單排班邏輯：週末1人，工作日2-3人
        let requiredStaff = isWeekend ? 1 : min(3, availableEmployees.count)
        let selectedEmployees = Array(availableEmployees.shuffled().prefix(requiredStaff))

        for (index, employee) in selectedEmployees.enumerated() {
            let (startTime, endTime, hours) = getShiftTime(for: index, isWeekend: isWeekend)

            let assignment = ShiftAssignment(
                employeeId: employee.employeeId ?? "",
                employeeName: employee.name,
                startTime: startTime,
                endTime: endTime,
                hours: hours,
                position: index == 0 ? "主班" : "副班"
            )
            assignments.append(assignment)
        }

        return DailyShift(
            date: date,
            assignments: assignments,
            isHoliday: isWeekend
        )
    }

    /// 獲取班次時間
    private func getShiftTime(for index: Int, isWeekend: Bool) -> (String, String, Double) {
        if isWeekend {
            return ("10:00", "18:00", 8.0)
        } else {
            switch index {
            case 0: return ("08:00", "16:00", 8.0)  // 早班
            case 1: return ("14:00", "22:00", 8.0)  // 晚班
            case 2: return ("10:00", "18:00", 8.0)  // 中班
            default: return ("09:00", "17:00", 8.0)
            }
        }
    }

    /// 計算員工工時統計
    func calculateWorkHours(schedule: WorkSchedule) -> [String: Double] {
        var workHours: [String: Double] = [:]

        for shift in schedule.shifts {
            for assignment in shift.assignments {
                workHours[assignment.employeeName, default: 0] += assignment.hours
            }
        }

        return workHours
    }

    /// 匯出班表為文字格式
    func exportScheduleText(_ schedule: WorkSchedule) -> String {
        var output = "📅 \(schedule.year)年\(schedule.month)月工作班表\n"
        output += "生成時間：\(DateFormatter.readable.string(from: schedule.generatedAt))\n\n"

        for shift in schedule.shifts {
            let dayOfWeek = shift.date.dayOfWeek.shortString
            output += "📍 \(shift.date.month)/\(shift.date.day) (\(dayOfWeek))\n"

            if shift.assignments.isEmpty {
                output += "   休息日\n"
            } else {
                for assignment in shift.assignments {
                    output += "   \(assignment.employeeName) \(assignment.startTime)-\(assignment.endTime) (\(assignment.position))\n"
                }
            }
            output += "\n"
        }

        // 工時統計
        let workHours = calculateWorkHours(schedule: schedule)
        output += "📊 本月工時統計：\n"
        for (name, hours) in workHours.sorted(by: { $0.value > $1.value }) {
            output += "   \(name)：\(Int(hours))小時\n"
        }

        return output
    }
}

// MARK: - DateFormatter 擴展
extension DateFormatter {
    static let readable: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "zh_TW")
        return formatter
    }()
}
