//
//  Payroll.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/9/17.
//

import Foundation

struct PayrollReport {
    let totalEarnings: Int
    let basePay: Int
    let overtimePay: Int
    let allowance: Int
    let deductions: Int
    let netPay: Int

    init(totalEarnings: Int = 0, basePay: Int = 0, overtimePay: Int = 0,
         allowance: Int = 0, deductions: Int = 0) {
        self.totalEarnings = totalEarnings
        self.basePay = basePay
        self.overtimePay = overtimePay
        self.allowance = allowance
        self.deductions = deductions
        self.netPay = totalEarnings - deductions
    }
}

struct IncomeDataPoint {
    let label: String
    let amount: Int
}

struct MonthlyGoals {
    let incomeTarget: Int
    let hoursTarget: Int
}
