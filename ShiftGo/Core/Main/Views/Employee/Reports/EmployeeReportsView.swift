//
//  EmployeeReportsView.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/8/25.
//

//
//  EmployeeReportsView.swift (Enhanced with Salary & Charts)
//  ShiftGo
//

import SwiftUI

struct EmployeeReportsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel = EmployeeReportsViewModel()

    @State private var selectedTimeRange: TimeRange = .thisMonth
    @State private var showingPayrollDetail = false

    enum TimeRange: String, CaseIterable {
        case thisWeek = "本週"
        case thisMonth = "本月"
        case lastMonth = "上月"
        case thisYear = "今年"

        var icon: String {
            switch self {
            case .thisWeek: return "calendar.day.timeline.left"
            case .thisMonth: return "calendar"
            case .lastMonth: return "calendar.badge.minus"
            case .thisYear: return "calendar.badge.checkmark"
            }
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection()
                    timeRangeSelector()

                    // 🔥 新增：薪資概覽卡片
                    salaryOverviewSection()

                    // 🔥 新增：收入趨勢圖表
                    incomeChartSection()

                    // 優化：工時統計
                    enhancedWorkHoursSection()

                    // 🔥 新增：月度目標追蹤
                    monthlyGoalSection()

                    // 優化：詳細統計
                    detailedStatsSection()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
            }
            .background(AppColors.Background.primary(colorScheme))
            .navigationTitle("薪資報表")
            .navigationBarHidden(true)
        }
        .onAppear {
            viewModel.loadReports(for: selectedTimeRange)
        }
        .onChange(of: selectedTimeRange) { _, newRange in
            viewModel.loadReports(for: newRange)
        }
        .sheet(isPresented: $showingPayrollDetail) {
//            PayrollDetailView(timeRange: selectedTimeRange, payrollData: viewModel.payrollReport)
        }
    }

    // MARK: - 🔥 新增：薪資概覽
    private func salaryOverviewSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("💰 薪資概覽")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppColors.Text.header(colorScheme))

                Spacer()

                Button("詳細") {
                    showingPayrollDetail = true
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.blue)
            }

            // 大數字顯示總收入
            VStack(spacing: 8) {
                Text("NT$ \(viewModel.payrollReport.totalEarnings.formatted())")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.green)

                Text(selectedTimeRange.rawValue + "總收入")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.green.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.green.opacity(0.3), lineWidth: 2)
                    )
            )

            // 薪資細分
            HStack(spacing: 12) {
                salaryBreakdownCard(
                    title: "基本薪資",
                    amount: viewModel.payrollReport.basePay,
                    icon: "dollarsign.circle.fill",
                    color: .blue
                )

                salaryBreakdownCard(
                    title: "加班費",
                    amount: viewModel.payrollReport.overtimePay,
                    icon: "clock.badge.fill",
                    color: .orange
                )

                salaryBreakdownCard(
                    title: "津貼",
                    amount: viewModel.payrollReport.allowance,
                    icon: "gift.fill",
                    color: .purple
                )
            }
        }
    }

    private func salaryBreakdownCard(title: String, amount: Int, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)

            Text("NT$ \(amount)")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(AppColors.Text.header(colorScheme))

            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }

    // MARK: - 🔥 新增：收入趨勢圖表
    private func incomeChartSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📈 收入趨勢")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppColors.Text.header(colorScheme))

            if viewModel.incomeData.isEmpty {
                // 空狀態
                VStack(spacing: 12) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)

                    Text("暫無收入數據")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                .frame(height: 120)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppColors.Background.secondary(colorScheme))
                )
            } else {
                // 簡易圖表實現
                VStack(spacing: 12) {
                    HStack(alignment: .bottom, spacing: 8) {
                        ForEach(Array(viewModel.incomeData.enumerated()), id: \.offset) { index, data in
                            VStack(spacing: 6) {
                                // 柱狀圖
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.blue, Color.blue.opacity(0.6)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .frame(width: 25, height: max(10, CGFloat(data.amount) / 200))
                                    .cornerRadius(4)

                                // 金額標籤
                                Text("\(formatNumber(data.amount))")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.blue)

                                // 日期標籤
                                Text(data.label)
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .frame(height: 120)

                    // 圖表說明 (🔥 修復除以零錯誤)
                    HStack {
                        let maxAmount = viewModel.incomeData.max(by: { $0.amount < $1.amount })?.amount ?? 0
                        Text("💡 最高收入：NT$ \(formatNumber(maxAmount))")

                        Spacer()

                        // 🔥 重要：檢查 count 是否大於 0 才計算平均
                        let totalAmount = viewModel.incomeData.map { $0.amount }.reduce(0, +)
                        let averageAmount = viewModel.incomeData.count > 0 ? totalAmount / viewModel.incomeData.count : 0
                        Text("平均：NT$ \(formatNumber(averageAmount))")
                    }
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppColors.Background.secondary(colorScheme))
                )
            }
        }
    }

    // MARK: - 🔥 新增：月度目標追蹤
    private func monthlyGoalSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🎯 本月目標")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppColors.Text.header(colorScheme))

            VStack(spacing: 16) {
                // 收入目標
                goalProgressCard(
                    title: "收入目標",
                    current: viewModel.payrollReport.totalEarnings,
                    target: viewModel.monthlyGoals.incomeTarget,
                    unit: "NT$",
                    color: .green,
                    icon: "target"
                )

                // 工時目標
                goalProgressCard(
                    title: "工時目標",
                    current: viewModel.workReport.totalHours,
                    target: viewModel.monthlyGoals.hoursTarget,
                    unit: "小時",
                    color: .blue,
                    icon: "clock"
                )
            }
        }
    }

    private func goalProgressCard(title: String, current: Int, target: Int, unit: String, color: Color, icon: String) -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)

                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppColors.Text.header(colorScheme))

                Spacer()

                Text("\(current) / \(target) \(unit)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(color)
            }

            // 進度條
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)

                    Rectangle()
                        .fill(color)
                        .frame(width: min(geometry.size.width, geometry.size.width * (Double(current) / Double(target))), height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)

            // 百分比和剩餘
            HStack {
                let progress = min(100, Int((Double(current) / Double(target)) * 100))
                Text("完成度：\(progress)%")
                    .font(.system(size: 12))
                    .foregroundColor(color)

                Spacer()

                let remaining = max(0, target - current)
                Text("還需：\(remaining) \(unit)")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
    }

    // MARK: - 其他區塊 (簡化版)
    private func headerSection() -> some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("薪資報表")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(AppColors.Text.header(colorScheme))

                    Text("追蹤您的收入與工時")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.7))
                }

                Spacer()

                // 🔥 新增：收入增長指示器
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: viewModel.incomeChange >= 0 ? "arrow.up.right" : "arrow.down.right")
                            .font(.system(size: 12))
                            .foregroundColor(viewModel.incomeChange >= 0 ? .green : .red)

                        Text("\(abs(viewModel.incomeChange))%")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(viewModel.incomeChange >= 0 ? .green : .red)
                    }

                    Text("vs 上月")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }

            if viewModel.isLoading {
                ProgressView()
                    .frame(height: 20)
            }
        }
        .padding(.top, 20)
    }

    private func timeRangeSelector() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(TimeRange.allCases, id: \.self) { range in
                    timeRangeButton(range)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func timeRangeButton(_ range: TimeRange) -> some View {
        Button(action: { selectedTimeRange = range }) {
            HStack(spacing: 8) {
                Image(systemName: range.icon)
                    .font(.system(size: 14))

                Text(range.rawValue)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(selectedTimeRange == range ? .white : AppColors.Text.header(colorScheme))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(selectedTimeRange == range ? Color.blue : AppColors.Background.secondary(colorScheme))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func enhancedWorkHoursSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("⏰ 工時統計")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppColors.Text.header(colorScheme))

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                workHoursCard(
                    title: "總工時",
                    value: "\(viewModel.workReport.totalHours)h",
                    icon: "clock.fill",
                    color: .blue,
                    subtitle: "時薪 NT$ \(viewModel.hourlyRate)"
                )

                workHoursCard(
                    title: "加班時數",
                    value: "\(viewModel.workReport.overtimeHours)h",
                    icon: "moon.stars.fill",
                    color: .orange,
                    subtitle: "1.33x 倍率"
                )

                workHoursCard(
                    title: "工作天數",
                    value: "\(viewModel.workReport.workDays)天",
                    icon: "calendar.badge.checkmark",
                    color: .green,
                    subtitle: "平均 \(String(format: "%.1f", viewModel.workReport.averageDailyHours))h/天"
                )

                workHoursCard(
                    title: "出勤率",
                    value: "\(Int(viewModel.workReport.attendanceRate * 100))%",
                    icon: "person.badge.shield.checkmark",
                    color: .purple,
                    subtitle: "遲到 \(viewModel.workReport.lateCount) 次"
                )
            }
        }
    }

    private func workHoursCard(title: String, value: String, icon: String, color: Color, subtitle: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)

            VStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppColors.Text.header(colorScheme))

                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppColors.Text.header(colorScheme))

                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }

    private func detailedStatsSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📊 詳細統計")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppColors.Text.header(colorScheme))

            VStack(spacing: 12) {
                statisticRow("每小時平均收入", "NT$ \(Int(Double(viewModel.payrollReport.totalEarnings) / Double(viewModel.workReport.totalHours)))", .green)
                statisticRow("最高單日工時", "\(viewModel.maxDailyHours)小時", .blue)
                statisticRow("本月排名", "第 \(viewModel.monthlyRanking) 名", .purple)
                statisticRow("連續出勤", "\(viewModel.consecutiveDays)天", .orange)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.Background.secondary(colorScheme))
            )
        }
    }

    private func statisticRow(_ title: String, _ value: String, _ color: Color) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(AppColors.Text.header(colorScheme))

            Spacer()

            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(color)
        }
    }
    // MARK: - Helper Methods
    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }

    // 🔥 新增：安全計算平均值的函數
    private func safeAverage(from data: [IncomeDataPoint]) -> Int {
        guard !data.isEmpty else { return 0 }
        let total = data.map { $0.amount }.reduce(0, +)
        return total / data.count
    }

    // 🔥 新增：安全獲取最大值的函數
    private func safeMaxAmount(from data: [IncomeDataPoint]) -> Int {
        return data.max(by: { $0.amount < $1.amount })?.amount ?? 0
    }
}

// MARK: - 🔥 新增：資料模型

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


#Preview {
    EmployeeReportsView()
        .environmentObject(ThemeManager())
}
