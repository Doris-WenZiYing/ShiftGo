//
//  EmployeeReportsView.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/8/25.
//

import SwiftUI

struct EmployeeReportsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel = EmployeeReportsViewModel()

    @State private var selectedTimeRange: TimeRange = .thisMonth
    @State private var showingPayrollDetail = false

    enum TimeRange: String, CaseIterable {
        case thisWeek = "This Week"
        case thisMonth = "This Month"
        case lastMonth = "Last Month"
        case thisYear = "This Year"

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
                VStack(spacing: DesignTokens.Spacing.xxl) {
                    headerSection()
                    timeRangeSelector()
                    salaryOverviewSection()
                    workHoursSection()
                    detailsSection()
                }
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.bottom, DesignTokens.Spacing.xxxl)
            }
            .background(AppColors.Background.primary(colorScheme))
            .navigationTitle("Payroll Reports")
            .navigationBarHidden(true)
        }
        .onAppear {
            viewModel.loadReports(for: selectedTimeRange)
        }
        .onChange(of: selectedTimeRange) { _, newRange in
            viewModel.loadReports(for: newRange)
        }
        .sheet(isPresented: $showingPayrollDetail) {
            PayrollDetailView(timeRange: selectedTimeRange, payrollData: viewModel.payrollReport)
        }
    }

    // MARK: - Header Section
    private func headerSection() -> some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text("Payroll Reports")
                        .font(DesignTokens.Typography.largeTitle)
                        .foregroundColor(AppColors.Text.header(colorScheme))

                    Text("View your income and work hours")
                        .font(DesignTokens.Typography.body)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.Theme.primary))
                        .scaleEffect(0.8)
                }
            }
        }
        .padding(.top, DesignTokens.Spacing.xl)
    }

    // MARK: - Time Range Selector
    private func timeRangeSelector() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignTokens.Spacing.md) {
                ForEach(TimeRange.allCases, id: \.self) { range in
                    timeRangeButton(range)
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)
        }
    }

    private func timeRangeButton(_ range: TimeRange) -> some View {
        Button(action: { selectedTimeRange = range }) {
            HStack(spacing: DesignTokens.Spacing.sm) {
                Image(systemName: range.icon)
                    .font(.system(size: 14))

                Text(range.rawValue)
                    .font(DesignTokens.Typography.captionMedium)
            }
            .foregroundColor(selectedTimeRange == range ? .white : AppColors.Text.header(colorScheme))
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.vertical, DesignTokens.Spacing.md)
            .background(
                Capsule()
                    .fill(selectedTimeRange == range ? AppColors.Theme.primary : AppColors.Background.secondary(colorScheme))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Salary Overview Section
    private func salaryOverviewSection() -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            SectionHeader("Salary Overview", actionTitle: "Details") {
                showingPayrollDetail = true
            }

            PrimaryCard {
                VStack(spacing: DesignTokens.Spacing.xl) {
                    // Total Earnings Display
                    VStack(spacing: DesignTokens.Spacing.sm) {
                        Text("Total Earnings")
                            .font(DesignTokens.Typography.caption)
                            .foregroundColor(.secondary)

                        Text("NT$ \(formatNumber(viewModel.payrollReport.totalEarnings))")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.Theme.primary)

                        Text(selectedTimeRange.rawValue)
                            .font(DesignTokens.Typography.small)
                            .foregroundColor(.secondary)
                    }

                    // Breakdown
                    VStack(spacing: DesignTokens.Spacing.md) {
                        salaryBreakdownRow("Base Salary", viewModel.payrollReport.basePay)
                        salaryBreakdownRow("Overtime Pay", viewModel.payrollReport.overtimePay)
                        salaryBreakdownRow("Allowance", viewModel.payrollReport.allowance)

                        if viewModel.payrollReport.deductions > 0 {
                            Divider()
                            salaryBreakdownRow("Deductions", viewModel.payrollReport.deductions, isDeduction: true)
                        }
                    }
                }
                .padding(DesignTokens.Spacing.xl)
            }
        }
    }

    private func salaryBreakdownRow(_ title: String, _ amount: Int, isDeduction: Bool = false) -> some View {
        HStack {
            Text(title)
                .font(DesignTokens.Typography.caption)
                .foregroundColor(AppColors.Text.header(colorScheme))

            Spacer()

            Text("\(isDeduction ? "-" : "")NT$ \(formatNumber(amount))")
                .font(DesignTokens.Typography.captionMedium)
                .foregroundColor(isDeduction ? .red : AppColors.Theme.primary)
        }
    }

    // MARK: - Work Hours Section
    private func workHoursSection() -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            SectionHeader("Work Hours Statistics")

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: DesignTokens.Spacing.md) {
                StatsCard(
                    title: "Total Hours",
                    value: "\(viewModel.workReport.totalHours)h",
                    subtitle: "Avg \(String(format: "%.1f", viewModel.workReport.averageDailyHours))h/day",
                    icon: "clock.fill",
                    color: AppColors.Theme.primary
                )

                StatsCard(
                    title: "Overtime Hours",
                    value: "\(viewModel.workReport.overtimeHours)h",
                    subtitle: "1.33x rate",
                    icon: "moon.stars.fill",
                    color: AppColors.Theme.primary
                )

                StatsCard(
                    title: "Work Days",
                    value: "\(viewModel.workReport.workDays) days",
                    subtitle: "Attendance \(Int(viewModel.workReport.attendanceRate * 100))%",
                    icon: "calendar.badge.checkmark",
                    color: AppColors.Theme.primary
                )

                StatsCard(
                    title: "Hourly Rate",
                    value: "NT$ \(viewModel.hourlyRate)",
                    subtitle: "Average earnings",
                    icon: "dollarsign.circle.fill",
                    color: AppColors.Theme.primary
                )
            }
        }
    }

    // MARK: - Details Section
    private func detailsSection() -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            SectionHeader("Detailed Statistics")

            PrimaryCard {
                VStack(spacing: DesignTokens.Spacing.md) {
                    detailRow("Average hourly earnings", "NT$ \(calculateHourlyEarnings())")
                    detailRow("Max daily hours", "\(viewModel.maxDailyHours) hours")
                    detailRow("Late arrivals", "\(viewModel.workReport.lateCount) times")
                    detailRow("Consecutive days", "\(viewModel.consecutiveDays) days")
                }
                .padding(DesignTokens.Spacing.lg)
            }
        }
    }

    private func detailRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .font(DesignTokens.Typography.caption)
                .foregroundColor(AppColors.Text.header(colorScheme))

            Spacer()

            Text(value)
                .font(DesignTokens.Typography.captionMedium)
                .foregroundColor(AppColors.Theme.primary)
        }
    }

    // MARK: - Helper Methods
    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }

    private func calculateHourlyEarnings() -> Int {
        guard viewModel.workReport.totalHours > 0 else { return 0 }
        return viewModel.payrollReport.totalEarnings / viewModel.workReport.totalHours
    }
}

#Preview {
    EmployeeReportsView()
        .environmentObject(ThemeManager())
}
