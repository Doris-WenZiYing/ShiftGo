//
//  WorkhoursDetailView.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/9/13.
//

import SwiftUI

struct WorkHoursDetailView: View {
    let timeRange: EmployeeReportsView.TimeRange
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var viewModel = WorkHoursDetailViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection()
                    dailyRecordsSection()
                    summarySection()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
            }
            .background(AppColors.Background.primary(colorScheme))
            .navigationTitle("工時詳情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("關閉") { dismiss() }
                        .foregroundColor(AppColors.Text.header(colorScheme))
                }
            }
        }
        .onAppear {
            viewModel.loadDetailedRecords(for: timeRange)
        }
    }

    // MARK: - Header Section
    private func headerSection() -> some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.badge.checkmark.fill")
                .font(.system(size: 40))
                .foregroundColor(.blue)

            VStack(spacing: 8) {
                Text("\(timeRange.rawValue)工時詳情")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppColors.Text.header(colorScheme))

                Text("詳細工作時間記錄")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.7))
            }
        }
        .padding(.top, 20)
    }

    // MARK: - Daily Records Section
    private func dailyRecordsSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📅 每日記錄")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppColors.Text.header(colorScheme))

            LazyVStack(spacing: 12) {
                ForEach(viewModel.dailyRecords, id: \.id) { record in
                    dailyRecordCard(record)
                }
            }
        }
    }

    private func dailyRecordCard(_ record: DailyWorkRecord) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(record.dateString)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.Text.header(colorScheme))

                    Text(record.dayOfWeek)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(record.totalHours)小時")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.blue)

                    statusBadge(record.status)
                }
            }

            if !record.isRestDay {
                VStack(spacing: 8) {
                    timeRow("上班時間", record.clockIn)
                    timeRow("下班時間", record.clockOut)
                    timeRow("休息時間", record.breakTime)

                    if record.overtimeHours > 0 {
                        HStack {
                            Text("加班時數")
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.Text.header(colorScheme))

                            Spacer()

                            Text("\(record.overtimeHours)小時")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.orange)
                        }
                    }
                }
                .padding(.top, 8)
            }

            if !record.note.isEmpty {
                Text("備註：\(record.note)")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.Background.secondary(colorScheme))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(record.status.color.opacity(0.3), lineWidth: 1)
                )
        )
    }

    private func timeRow(_ title: String, _ time: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(AppColors.Text.header(colorScheme))

            Spacer()

            Text(time)
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundColor(.blue)
        }
    }

    private func statusBadge(_ status: AttendanceStatus) -> some View {
        Text(status.displayText)
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(status.color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(status.color.opacity(0.1))
            )
    }

    // MARK: - Summary Section
    private func summarySection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📊 統計摘要")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppColors.Text.header(colorScheme))

            VStack(spacing: 12) {
                summaryRow("總工時", "\(viewModel.totalHours)小時", .blue)
                summaryRow("總工作天數", "\(viewModel.totalWorkDays)天", .green)
                summaryRow("加班時數", "\(viewModel.totalOvertimeHours)小時", .orange)
                summaryRow("請假天數", "\(viewModel.totalLeaveDays)天", .gray)
                summaryRow("遲到次數", "\(viewModel.lateCount)次", .red)

                Divider()

                HStack {
                    Text("平均每日工時")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.Text.header(colorScheme))

                    Spacer()

                    Text(String(format: "%.1f小時", viewModel.averageDailyHours))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.blue)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.Background.secondary(colorScheme))
            )
        }
    }

    private func summaryRow(_ title: String, _ value: String, _ color: Color) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(AppColors.Text.header(colorScheme))

            Spacer()

            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)
        }
    }
}

// MARK: - Data Models

struct DailyWorkRecord: Identifiable {
    let id = UUID()
    let dateString: String
    let dayOfWeek: String
    let clockIn: String
    let clockOut: String
    let breakTime: String
    let totalHours: Int
    let overtimeHours: Int
    let status: AttendanceStatus
    let note: String
    let isRestDay: Bool
}

class WorkHoursDetailViewModel: ObservableObject {
    @Published var dailyRecords: [DailyWorkRecord] = []
    @Published var totalHours: Int = 0
    @Published var totalWorkDays: Int = 0
    @Published var totalOvertimeHours: Int = 0
    @Published var totalLeaveDays: Int = 0
    @Published var lateCount: Int = 0
    @Published var averageDailyHours: Double = 0.0

    func loadDetailedRecords(for timeRange: EmployeeReportsView.TimeRange) {
        // 生成模擬數據
        generateMockRecords(for: timeRange)
        calculateSummary()
    }

    private func generateMockRecords(for timeRange: EmployeeReportsView.TimeRange) {
        // 根據時間範圍生成不同的數據
        switch timeRange {
        case .thisMonth:
            dailyRecords = generateMonthlyRecords()
        case .thisWeek:
            dailyRecords = generateWeeklyRecords()
        default:
            dailyRecords = generateMonthlyRecords()
        }
    }

    private func generateMonthlyRecords() -> [DailyWorkRecord] {
        return [
            DailyWorkRecord(dateString: "2025/09/13", dayOfWeek: "週五", clockIn: "09:00", clockOut: "18:00", breakTime: "1小時", totalHours: 8, overtimeHours: 0, status: .normal, note: "", isRestDay: false),
            DailyWorkRecord(dateString: "2025/09/12", dayOfWeek: "週四", clockIn: "09:15", clockOut: "18:00", breakTime: "1小時", totalHours: 8, overtimeHours: 0, status: .late, note: "交通堵塞", isRestDay: false),
            DailyWorkRecord(dateString: "2025/09/11", dayOfWeek: "週三", clockIn: "09:00", clockOut: "19:30", breakTime: "1小時", totalHours: 9, overtimeHours: 2, status: .overtime, note: "完成專案", isRestDay: false),
            DailyWorkRecord(dateString: "2025/09/10", dayOfWeek: "週二", clockIn: "09:00", clockOut: "18:00", breakTime: "1小時", totalHours: 8, overtimeHours: 0, status: .normal, note: "", isRestDay: false),
            DailyWorkRecord(dateString: "2025/09/09", dayOfWeek: "週一", clockIn: "-", clockOut: "-", breakTime: "-", totalHours: 0, overtimeHours: 0, status: .leave, note: "病假", isRestDay: true),
        ]
    }

    private func generateWeeklyRecords() -> [DailyWorkRecord] {
        return Array(generateMonthlyRecords().prefix(5))
    }

    private func calculateSummary() {
        totalHours = dailyRecords.reduce(0) { $0 + $1.totalHours }
        totalWorkDays = dailyRecords.filter { !$0.isRestDay && $0.totalHours > 0 }.count
        totalOvertimeHours = dailyRecords.reduce(0) { $0 + $1.overtimeHours }
        totalLeaveDays = dailyRecords.filter { $0.status == .leave }.count
        lateCount = dailyRecords.filter { $0.status == .late }.count
        averageDailyHours = totalWorkDays > 0 ? Double(totalHours) / Double(totalWorkDays) : 0.0
    }
}

#Preview {
    WorkHoursDetailView(timeRange: .thisMonth)
}
