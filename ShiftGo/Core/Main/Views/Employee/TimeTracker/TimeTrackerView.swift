//
//  TimeTrackerView.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/8/26.
//

import SwiftUI

struct TimeTrackerView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel = TimeTrackerViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: DesignTokens.Spacing.xxl) {
                    headerSection()
                    clockSection()
                    todayOverviewSection()
                    recentRecordsSection()
                }
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.bottom, DesignTokens.Spacing.xxxl)
            }
            .background(AppColors.Background.primary(colorScheme))
            .navigationTitle("Time Clock")
            .navigationBarHidden(true)
        }
        .onAppear {
            viewModel.loadTodayStatus()
        }
    }

    // MARK: - Header Section
    private func headerSection() -> some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text("Time Clock")
                        .font(DesignTokens.Typography.largeTitle)
                        .foregroundColor(AppColors.Text.header(colorScheme))

                    Text("Track your work hours")
                        .font(DesignTokens.Typography.body)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: DesignTokens.Spacing.xs) {
                    Text(viewModel.currentTime)
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .foregroundColor(AppColors.Theme.primary)

                    Text("Current Time")
                        .font(DesignTokens.Typography.small)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.top, DesignTokens.Spacing.xl)
    }

    // MARK: - Clock Section
    private func clockSection() -> some View {
        PrimaryCard {
            VStack(spacing: DesignTokens.Spacing.xxl) {
                // Status Display
                VStack(spacing: DesignTokens.Spacing.lg) {
                    ZStack {
                        Circle()
                            .fill(AppColors.Theme.primary.opacity(0.1))
                            .frame(width: 120, height: 120)

                        Circle()
                            .stroke(AppColors.Theme.primary.opacity(0.2), lineWidth: 2)
                            .frame(width: 120, height: 120)

                        VStack(spacing: DesignTokens.Spacing.xs) {
                            Image(systemName: viewModel.isWorking ? "play.circle.fill" : "pause.circle")
                                .font(.system(size: 32))
                                .foregroundColor(AppColors.Theme.primary)

                            Text(viewModel.isWorking ? "Working" : "Resting")
                                .font(DesignTokens.Typography.captionMedium)
                                .foregroundColor(AppColors.Text.header(colorScheme))
                        }
                    }

                    if viewModel.isWorking {
                        VStack(spacing: DesignTokens.Spacing.xs) {
                            if let startTime = viewModel.todayWorkStart {
                                Text("Started: \(formatTime(startTime))")
                                    .font(DesignTokens.Typography.caption)
                                    .foregroundColor(.secondary)
                            }

                            Text(viewModel.currentWorkDuration)
                                .font(.system(size: 24, weight: .bold, design: .monospaced))
                                .foregroundColor(AppColors.Theme.primary)
                        }
                    }
                }

                // Action Buttons
                HStack(spacing: DesignTokens.Spacing.md) {
                    if !viewModel.isWorking {
                        PrimaryButton("Clock In", icon: "play.fill") {
                            viewModel.clockIn()
                        }
                    } else {
                        PrimaryButton("Break", icon: "pause.fill", style: .secondary) {
                            viewModel.startBreak()
                        }

                        PrimaryButton("Clock Out", icon: "stop.fill", style: .destructive) {
                            viewModel.clockOut()
                        }
                    }
                }
            }
            .padding(DesignTokens.Spacing.xxl)
        }
    }

    // MARK: - Today Overview
    private func todayOverviewSection() -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            SectionHeader("Today's Overview")

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: DesignTokens.Spacing.md) {
                StatsCard(
                    title: "Total Hours",
                    value: viewModel.todayTotalHours,
                    icon: "clock.fill",
                    color: AppColors.Theme.primary
                )

                StatsCard(
                    title: "Break Time",
                    value: viewModel.todayBreakTime,
                    icon: "cup.and.saucer.fill",
                    color: AppColors.Theme.primary
                )

                StatsCard(
                    title: "Overtime",
                    value: viewModel.todayOvertimeHours,
                    icon: "moon.stars.fill",
                    color: AppColors.Theme.primary
                )
            }
        }
    }

    // MARK: - Recent Records
    private func recentRecordsSection() -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            SectionHeader("Recent Records")

            PrimaryCard {
                LazyVStack(spacing: DesignTokens.Spacing.md) {
                    ForEach(viewModel.recentRecords.prefix(5), id: \.id) { record in
                        recordRow(record)

                        if record.id != viewModel.recentRecords.prefix(5).last?.id {
                            Divider()
                        }
                    }
                }
                .padding(DesignTokens.Spacing.lg)
            }
        }
    }

    private func recordRow(_ record: TimeRecord) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text(record.dateString)
                    .font(DesignTokens.Typography.bodyMedium)
                    .foregroundColor(AppColors.Text.header(colorScheme))

                Text("\(record.clockIn) - \(record.clockOut ?? "In Progress")")
                    .font(DesignTokens.Typography.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: DesignTokens.Spacing.xs) {
                Text("\(record.totalHours)h")
                    .font(DesignTokens.Typography.bodyMedium)
                    .foregroundColor(AppColors.Theme.primary)

                Text(record.status.displayText)
                    .font(DesignTokens.Typography.small)
                    .foregroundColor(getStatusColor(record.status))
                    .padding(.horizontal, DesignTokens.Spacing.sm)
                    .padding(.vertical, DesignTokens.Spacing.xs)
                    .background(
                        Capsule()
                            .fill(getStatusColor(record.status).opacity(0.1))
                    )
            }
        }
    }

    // MARK: - Helper Functions
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "zh_TW")
        return formatter.string(from: date)
    }

    private func getStatusColor(_ status: AttendanceStatus) -> Color {
        switch status {
        case .normal:
            return AppColors.Theme.primary
        case .late:
            return .orange
        case .overtime:
            return AppColors.Theme.primary
        case .leave:
            return .gray
        case .absent:
            return .red
        }
    }
}

#Preview {
    TimeTrackerView()
        .environmentObject(ThemeManager())
}
