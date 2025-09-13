//
//  EmployeeReportsViewModel.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/9/13.
//

import Foundation

class EmployeeReportsViewModel: ObservableObject {
    @Published var workReport = WorkReport()
    @Published var payrollReport = PayrollReport()
    @Published var incomeData: [IncomeDataPoint] = []
    @Published var monthlyGoals = MonthlyGoals(incomeTarget: 50000, hoursTarget: 160)
    @Published var isLoading = false

    // 新增屬性
    @Published var hourlyRate = 200
    @Published var incomeChange = 15
    @Published var maxDailyHours = 12
    @Published var monthlyRanking = 3
    @Published var consecutiveDays = 8

    init() {
        generateMockData(for: .thisMonth)
    }

    func loadReports(for timeRange: EmployeeReportsView.TimeRange) {
        isLoading = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.generateMockData(for: timeRange)
            self.isLoading = false
        }
    }

    private func generateMockData(for timeRange: EmployeeReportsView.TimeRange) {
        switch timeRange {
        case .thisMonth:
            workReport = WorkReport(
                totalHours: 168,
                workDays: 21,
                averageDailyHours: 8.0,
                overtimeHours: 12,
                attendanceRate: 0.96,
                punctualityRate: 0.92,
                leaveDays: 2,
                lateCount: 3
            )

            payrollReport = PayrollReport(
                totalEarnings: 42000,
                basePay: 33600, // 168 * 200
                overtimePay: 3200, // 12 * 200 * 1.33
                allowance: 5200,
                deductions: 2000
            )

            incomeData = [
                IncomeDataPoint(label: "第1週", amount: 8000),
                IncomeDataPoint(label: "第2週", amount: 10500),
                IncomeDataPoint(label: "第3週", amount: 12000),
                IncomeDataPoint(label: "第4週", amount: 11500)
            ]

        case .thisWeek:
            workReport = WorkReport(totalHours: 32, workDays: 4, averageDailyHours: 8.0, overtimeHours: 2)
            payrollReport = PayrollReport(totalEarnings: 6933, basePay: 6400, overtimePay: 533, allowance: 0)
            incomeData = [
                IncomeDataPoint(label: "週一", amount: 1600),
                IncomeDataPoint(label: "週二", amount: 1867),
                IncomeDataPoint(label: "週三", amount: 1600),
                IncomeDataPoint(label: "週四", amount: 1866)
            ]

        default:
            workReport = WorkReport()
            payrollReport = PayrollReport()
            incomeData = []
        }
    }
}

struct WorkReport {
    let totalHours: Int
    let workDays: Int
    let averageDailyHours: Double
    let overtimeHours: Int
    let attendanceRate: Double
    let punctualityRate: Double
    let leaveDays: Int
    let lateCount: Int

    init(totalHours: Int = 0, workDays: Int = 0, averageDailyHours: Double = 0,
         overtimeHours: Int = 0, attendanceRate: Double = 0, punctualityRate: Double = 0,
         leaveDays: Int = 0, lateCount: Int = 0) {
        self.totalHours = totalHours
        self.workDays = workDays
        self.averageDailyHours = averageDailyHours
        self.overtimeHours = overtimeHours
        self.attendanceRate = attendanceRate
        self.punctualityRate = punctualityRate
        self.leaveDays = leaveDays
        self.lateCount = lateCount
    }
}
