//
//  VacationSettingsView.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/8/26.
//

import SwiftUI

struct VacationSettingsView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: BossMainViewModel

    @State private var settings = VacationSettings()
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var selectedYear = Calendar.current.component(.year, from: Date())

    // 彈性限制設定
    @State private var enableMonthlyLimit = true
    @State private var enableWeeklyLimit = false
    @State private var monthlyLimit = 8
    @State private var weeklyLimit = 2

    private let months = [
        1: "1月", 2: "2月", 3: "3月", 4: "4月",
        5: "5月", 6: "6月", 7: "7月", 8: "8月",
        9: "9月", 10: "10月", 11: "11月", 12: "12月"
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection()
                    monthSelectionSection()
                    limitTypeSection()
                    vacationLimitsSection()
                    deadlineSection()
                    previewSection()
                    publishButtonSection()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .background(AppColors.Background.primary(colorScheme))
            .navigationTitle("發佈排休")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") { dismiss() }
                        .foregroundColor(.blue)
                }
            }
        }
        .onAppear {
            initializeSettings()
        }
    }

    // MARK: - Header Section
    private func headerSection() -> some View {
        VStack(spacing: 16) {
            // Icon and Title
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [.green, .blue]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 80, height: 80)

                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundColor(.white)
                }

                VStack(spacing: 6) {
                    Text("發佈排休")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(AppColors.Text.header(colorScheme))

                    Text("設定排休規則並開放員工申請")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.7))
                        .multilineTextAlignment(.center)
                }
            }
        }
    }

    // MARK: - Month Selection Section
    private func monthSelectionSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("選擇發佈月份", icon: "calendar")

            VStack(spacing: 16) {
                // Year and Month in one card
                VStack(spacing: 20) {
                    HStack(spacing: 16) {
                        // Year Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("年份")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.8))

                            Menu {
                                ForEach(2024...2026, id: \.self) { year in
                                    Button("\(year)年") { selectedYear = year }
                                }
                            } label: {
                                HStack {
                                    Text("\(selectedYear)年")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.blue)

                                    Spacer()

                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 14))
                                        .foregroundColor(.blue)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.blue.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                        }

                        // Month Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("月份")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.8))

                            Menu {
                                ForEach(1...12, id: \.self) { month in
                                    Button(months[month] ?? "") { selectedMonth = month }
                                }
                            } label: {
                                HStack {
                                    Text(months[selectedMonth] ?? "")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.green)

                                    Spacer()

                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 14))
                                        .foregroundColor(.green)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.green.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.green.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                        }
                    }
                }
                .padding(20)
                .background(settingCardBackground())
            }
        }
    }

    // MARK: - Limit Type Section
    private func limitTypeSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("排休限制設定", icon: "slider.horizontal.3")

            VStack(spacing: 16) {
                // Monthly Limit Toggle
                limitToggleCard(
                    title: "月排休限制",
                    description: "設定每月排休天數上限",
                    icon: "calendar",
                    color: .orange,
                    isEnabled: $enableMonthlyLimit,
                    limit: $monthlyLimit,
                    range: 1...31,
                    unit: "天/月"
                )

                // Weekly Limit Toggle
                limitToggleCard(
                    title: "週排休限制",
                    description: "設定每週排休天數上限",
                    icon: "calendar.day.timeline.left",
                    color: .purple,
                    isEnabled: $enableWeeklyLimit,
                    limit: $weeklyLimit,
                    range: 1...7,
                    unit: "天/週"
                )
            }
        }
    }

    private func limitToggleCard(
        title: String,
        description: String,
        icon: String,
        color: Color,
        isEnabled: Binding<Bool>,
        limit: Binding<Int>,
        range: ClosedRange<Int>,
        unit: String
    ) -> some View {
        VStack(spacing: 16) {
            HStack {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(color)
                        .frame(width: 32)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.Text.header(colorScheme))

                        Text(description)
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.6))
                    }
                }

                Spacer()

                Toggle("", isOn: isEnabled)
                    .toggleStyle(SwitchToggleStyle(tint: color))
            }

            if isEnabled.wrappedValue {
                VStack(spacing: 12) {
                    HStack {
                        Text("上限設定")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.8))

                        Spacer()

                        Text("\(limit.wrappedValue) \(unit)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(color)
                    }

                    HStack {
                        Text("\(range.lowerBound)")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.5))

                        Slider(
                            value: Binding(
                                get: { Double(limit.wrappedValue) },
                                set: { limit.wrappedValue = Int($0) }
                            ),
                            in: Double(range.lowerBound)...Double(range.upperBound),
                            step: 1
                        )
                        .accentColor(color)

                        Text("\(range.upperBound)")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.5))
                    }
                }
                .padding(.top, 8)
                .transition(.slide)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isEnabled.wrappedValue ? color.opacity(0.05) : AppColors.Background.primary(colorScheme))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            isEnabled.wrappedValue ? color.opacity(0.3) : AppColors.Text.header(colorScheme).opacity(0.1),
                            lineWidth: 1
                        )
                )
        )
        .animation(.easeInOut(duration: 0.3), value: isEnabled.wrappedValue)
    }

    // MARK: - Vacation Limits Section (Removed - integrated into limit type section)
    private func vacationLimitsSection() -> some View {
        // This section is now integrated into limitTypeSection
        EmptyView()
    }

    // MARK: - Deadline Section
    private func deadlineSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("申請截止時間", icon: "clock")

            VStack(spacing: 16) {
                DatePicker(
                    "截止日期",
                    selection: $settings.deadline,
                    in: Date()...,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.compact)
                .accentColor(.blue)
                .padding(20)
                .background(settingCardBackground())

                HStack {
                    Image(systemName: "info.circle")
                        .font(.system(size: 14))
                        .foregroundColor(.blue)

                    Text("員工必須在此時間前提交排休申請")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.7))

                    Spacer()
                }
                .padding(.horizontal, 4)
            }
        }
    }

    // MARK: - Preview Section
    private func previewSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("發佈預覽", icon: "eye")

            VStack(alignment: .leading, spacing: 12) {
                previewRow(title: "目標月份", value: "\(selectedYear)年\(months[selectedMonth] ?? "")", color: .blue)

                if enableMonthlyLimit {
                    previewRow(title: "月排休上限", value: "\(monthlyLimit)天", color: .orange)
                }

                if enableWeeklyLimit {
                    previewRow(title: "週排休上限", value: "\(weeklyLimit)天", color: .purple)
                }

                previewRow(title: "申請截止", value: formatDate(settings.deadline), color: .red)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [
                            Color.blue.opacity(0.05),
                            Color.green.opacity(0.05)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [.blue.opacity(0.3), .green.opacity(0.3)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
        }
    }

    // MARK: - Publish Button Section
    private func publishButtonSection() -> some View {
        VStack(spacing: 16) {
            if !enableMonthlyLimit && !enableWeeklyLimit {
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.orange)

                    Text("請至少啟用一種排休限制")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.orange)

                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.orange.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                        )
                )
            }

            Button(action: publishSettings) {
                HStack(spacing: 12) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.9)
                    } else {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 18))
                    }

                    Text(viewModel.isLoading ? "發佈中..." : "發佈排休")
                        .font(.system(size: 18, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            isPublishEnabled ? .blue : .gray,
                            isPublishEnabled ? .green : .gray.opacity(0.8)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(
                    color: isPublishEnabled ? .blue.opacity(0.3) : .clear,
                    radius: 8,
                    x: 0,
                    y: 4
                )
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(!isPublishEnabled || viewModel.isLoading)
            .scaleEffect(viewModel.isLoading ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: viewModel.isLoading)
        }
    }

    // MARK: - Helper Views and Methods

    private func sectionTitle(_ title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.blue)

            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppColors.Text.header(colorScheme))

            Spacer()
        }
    }

    private func settingCardBackground() -> some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(AppColors.Background.primary(colorScheme))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppColors.Text.header(colorScheme).opacity(0.1), lineWidth: 1)
            )
    }

    private func previewRow(title: String, value: String, color: Color) -> some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)

            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.8))

            Spacer()

            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)
        }
    }

    private var isPublishEnabled: Bool {
        (enableMonthlyLimit || enableWeeklyLimit) && !viewModel.isLoading
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "zh_TW")
        return formatter.string(from: date)
    }

    private func initializeSettings() {
        settings.targetYear = selectedYear
        settings.targetMonth = months[selectedMonth] ?? ""
        settings.deadline = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    }

    private func publishSettings() {
        // 根據啟用的限制類型設定數值
        settings.targetYear = selectedYear
        settings.targetMonth = months[selectedMonth] ?? ""
        settings.maxDaysPerMonth = enableMonthlyLimit ? monthlyLimit : 0
        settings.maxDaysPerWeek = enableWeeklyLimit ? weeklyLimit : 0
        settings.limitType = enableMonthlyLimit ? .monthly : .weekly

        viewModel.publishVacationSettings(settings)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            dismiss()
        }
    }
}

#Preview {
    VacationSettingsView(viewModel: BossMainViewModel())
}
