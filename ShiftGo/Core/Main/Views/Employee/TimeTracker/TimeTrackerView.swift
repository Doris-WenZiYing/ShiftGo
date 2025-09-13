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
                VStack(spacing: 24) {
                    headerSection()

                    // 🔥 打卡區域
                    clockInOutSection()

                    // 🔥 今日工作狀態
                    todayStatusSection()

                    // 🔥 本週工作時間
                    weeklyTimeSection()

                    // 🔥 快速操作
                    quickActionsSection()

                    // 🔥 最近打卡記錄
                    recentRecordsSection()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
            }
            .background(AppColors.Background.primary(colorScheme))
            .navigationTitle("時間管理")
            .navigationBarHidden(true)
        }
        .onAppear {
            viewModel.loadTodayStatus()
        }
    }

    // MARK: - Header Section
    private func headerSection() -> some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("時間管理")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(AppColors.Text.header(colorScheme))

                    Text("精準記錄您的工作時間")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.7))
                }

                Spacer()

                // 即時時間
                VStack(alignment: .trailing, spacing: 2) {
                    Text(viewModel.currentTime)
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(.blue)

                    Text("現在時間")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.top, 20)
    }

    // MARK: - 🔥 打卡區域
    private func clockInOutSection() -> some View {
        VStack(spacing: 20) {
            // 當前狀態顯示
            VStack(spacing: 12) {
                Image(systemName: viewModel.isWorking ? "play.circle.fill" : "pause.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(viewModel.isWorking ? .green : .orange)

                Text(viewModel.isWorking ? "工作中" : "休息中")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppColors.Text.header(colorScheme))

                if viewModel.isWorking, let startTime = viewModel.todayWorkStart {
                    Text("開始時間：\(formatTime(startTime))")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)

                    Text("已工作：\(viewModel.currentWorkDuration)")
                        .font(.system(size: 18, weight: .semibold, design: .monospaced))
                        .foregroundColor(.blue)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: viewModel.isWorking ?
                                [Color.green.opacity(0.1), Color.green.opacity(0.05)] :
                                [Color.orange.opacity(0.1), Color.orange.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                viewModel.isWorking ? Color.green.opacity(0.3) : Color.orange.opacity(0.3),
                                lineWidth: 2
                            )
                    )
            )

            // 打卡按鈕
            HStack(spacing: 16) {
                if !viewModel.isWorking {
                    Button(action: { viewModel.clockIn() }) {
                        HStack(spacing: 8) {
                            Image(systemName: "play.fill")
                            Text("上班打卡")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.green)
                        .cornerRadius(12)
                    }
                } else {
                    Button(action: { viewModel.startBreak() }) {
                        HStack(spacing: 8) {
                            Image(systemName: "pause.fill")
                            Text("開始休息")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.orange)
                        .cornerRadius(12)
                    }

                    Button(action: { viewModel.clockOut() }) {
                        HStack(spacing: 8) {
                            Image(systemName: "stop.fill")
                            Text("下班打卡")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.red)
                        .cornerRadius(12)
                    }
                }
            }
        }
    }

    // MARK: - 今日狀態
    private func todayStatusSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📅 今日工作")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppColors.Text.header(colorScheme))

            HStack(spacing: 12) {
                statusCard(
                    title: "總工時",
                    value: viewModel.todayTotalHours,
                    icon: "clock.fill",
                    color: .blue
                )

                statusCard(
                    title: "休息時間",
                    value: viewModel.todayBreakTime,
                    icon: "cup.and.saucer.fill",
                    color: .orange
                )

                statusCard(
                    title: "加班時數",
                    value: viewModel.todayOvertimeHours,
                    icon: "moon.stars.fill",
                    color: .purple
                )
            }
        }
    }

    private func statusCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)

            Text(value)
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

    // MARK: - 本週統計
    private func weeklyTimeSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📊 本週統計")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppColors.Text.header(colorScheme))

            // 週工時圖表（簡化版）
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array(viewModel.weeklyData.enumerated()), id: \.offset) { index, data in
                    VStack(spacing: 6) {
                        Rectangle()
                            .fill(Color.blue)
                            .frame(width: 30, height: CGFloat(data.hours) * 8)
                            .cornerRadius(4)

                        Text("\(data.hours)")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.blue)

                        Text(data.day)
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.Background.secondary(colorScheme))
            )
        }
    }

    // MARK: - 快速操作
    private func quickActionsSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("⚡ 快速操作")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppColors.Text.header(colorScheme))

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                quickActionButton("申請加班", "clock.badge", .orange) {
                    // 申請加班邏輯
                }

                quickActionButton("調整工時", "slider.horizontal.3", .blue) {
                    // 調整工時邏輯
                }

                quickActionButton("查看班表", "calendar", .green) {
                    // 查看班表邏輯
                }

                quickActionButton("工時報告", "chart.bar", .purple) {
                    // 工時報告邏輯
                }
            }
        }
    }

    private func quickActionButton(_ title: String, _ icon: String, _ color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)

                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppColors.Text.header(colorScheme))
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
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - 最近記錄
    private func recentRecordsSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📝 最近記錄")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppColors.Text.header(colorScheme))

            LazyVStack(spacing: 8) {
                ForEach(viewModel.recentRecords, id: \.id) { record in
                    recordRow(record)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.Background.secondary(colorScheme))
            )
        }
    }

    private func recordRow(_ record: TimeRecord) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(record.dateString)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppColors.Text.header(colorScheme))

                Text("\(record.clockIn) - \(record.clockOut ?? "進行中")")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(record.totalHours)小時")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.blue)

                Text(record.status.displayText)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(record.status.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(record.status.color.opacity(0.1))
                    )
            }
        }
        .padding(.vertical, 8)
    }

    // MARK: - Helper Functions
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "zh_TW")
        return formatter.string(from: date)
    }
}
#Preview {
    TimeTrackerView()
        .environmentObject(ThemeManager())
}
