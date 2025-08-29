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

    private let months = [
        1: "1月", 2: "2月", 3: "3月", 4: "4月",
        5: "5月", 6: "6月", 7: "7月", 8: "8月",
        9: "9月", 10: "10月", 11: "11月", 12: "12月"
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection()

                    // Month Selection
                    monthSelectionSection()

                    // Vacation Limits
                    vacationLimitsSection()

                    // Deadline Setting
                    deadlineSection()

                    // Publish Button
                    publishButtonSection()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
            }
            .background(AppColors.Background.primary(colorScheme))
            .navigationTitle("發佈排休")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.Text.header(colorScheme))
                }
            }
        }
        .onAppear {
            initializeSettings()
        }
    }

    // MARK: - Header Section
    private func headerSection() -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 32))
                    .foregroundColor(.green)

                VStack(alignment: .leading, spacing: 4) {
                    Text("發佈排休")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppColors.Text.header(colorScheme))

                    Text("設定排休規則並開放員工申請")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.7))
                }

                Spacer()
            }
        }
        .padding(.vertical, 12)
    }

    // MARK: - Month Selection Section
    private func monthSelectionSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("選擇發佈月份")

            VStack(spacing: 16) {
                // Year Selector
                HStack {
                    Text("年份")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppColors.Text.header(colorScheme))

                    Spacer()

                    Picker("選擇年份", selection: $selectedYear) {
                        ForEach(2024...2026, id: \.self) { year in
                            Text("\(year)年").tag(year)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .accentColor(AppColors.Calendar.saturday)
                }
                .padding(16)
                .background(settingCardBackground())

                // Month Selector
                HStack {
                    Text("月份")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppColors.Text.header(colorScheme))

                    Spacer()

                    Picker("選擇月份", selection: $selectedMonth) {
                        ForEach(1...12, id: \.self) { month in
                            Text(months[month] ?? "").tag(month)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .accentColor(AppColors.Calendar.saturday)
                }
                .padding(16)
                .background(settingCardBackground())
            }
        }
    }

    // MARK: - Vacation Limits Section
    private func vacationLimitsSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("排休限制設定")

            VStack(spacing: 16) {
                // Limit Type
                HStack {
                    Text("限制類型")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppColors.Text.header(colorScheme))

                    Spacer()

                    Picker("限制類型", selection: $settings.limitType) {
                        ForEach(VacationLimitType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .accentColor(AppColors.Calendar.saturday)
                }
                .padding(16)
                .background(settingCardBackground())

                // Max Days Per Month
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("月排休上限")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AppColors.Text.header(colorScheme))

                        Spacer()

                        Text("\(settings.maxDaysPerMonth) 天")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.Calendar.saturday)
                    }

                    HStack {
                        Text("1")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.6))

                        Slider(value: Binding(
                            get: { Double(settings.maxDaysPerMonth) },
                            set: { settings.maxDaysPerMonth = Int($0) }
                        ), in: 1...15, step: 1)
                        .accentColor(AppColors.Calendar.saturday)

                        Text("15")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.6))
                    }
                }
                .padding(16)
                .background(settingCardBackground())

                // Max Days Per Week
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("週排休上限")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AppColors.Text.header(colorScheme))

                        Spacer()

                        Text("\(settings.maxDaysPerWeek) 天")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.Calendar.sunday)
                    }

                    HStack {
                        Text("1")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.6))

                        Slider(value: Binding(
                            get: { Double(settings.maxDaysPerWeek) },
                            set: { settings.maxDaysPerWeek = Int($0) }
                        ), in: 1...7, step: 1)
                        .accentColor(AppColors.Calendar.sunday)

                        Text("7")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.6))
                    }
                }
                .padding(16)
                .background(settingCardBackground())
            }
        }
    }

    // MARK: - Deadline Section
    private func deadlineSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("申請截止時間")

            VStack(alignment: .leading, spacing: 12) {
                DatePicker(
                    "截止日期",
                    selection: $settings.deadline,
                    in: Date()...,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(CompactDatePickerStyle())
                .accentColor(AppColors.Calendar.saturday)

                Text("員工必須在此時間前提交排休申請")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.6))
            }
            .padding(16)
            .background(settingCardBackground())
        }
    }

    // MARK: - Publish Button Section
    private func publishButtonSection() -> some View {
        VStack(spacing: 16) {
            // Preview Card
            VStack(alignment: .leading, spacing: 12) {
                Text("發佈預覽")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.Text.header(colorScheme))

                VStack(alignment: .leading, spacing: 8) {
                    previewRow(title: "目標月份", value: "\(selectedYear)年\(months[selectedMonth] ?? "")")
                    previewRow(title: "限制類型", value: settings.limitType.rawValue)
                    previewRow(title: "月上限", value: "\(settings.maxDaysPerMonth)天")
                    previewRow(title: "週上限", value: "\(settings.maxDaysPerWeek)天")
                    previewRow(title: "截止時間", value: formatDate(settings.deadline))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.Calendar.saturday.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppColors.Calendar.saturday.opacity(0.2), lineWidth: 1)
                    )
            )

            // Publish Button
            Button(action: publishSettings) {
                HStack(spacing: 8) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "paperplane.fill")
                    }

                    Text(viewModel.isLoading ? "發佈中..." : "發佈排休")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(AppColors.Calendar.saturday)
                .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(viewModel.isLoading)
            .opacity(viewModel.isLoading ? 0.8 : 1.0)
        }
    }

    // MARK: - Helper Methods

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(AppColors.Text.header(colorScheme))
    }

    private func settingCardBackground() -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(AppColors.Background.primary(colorScheme))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppColors.Text.header(colorScheme).opacity(0.1), lineWidth: 1)
            )
    }

    private func previewRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.7))

            Spacer()

            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppColors.Calendar.saturday)
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
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
        settings.targetYear = selectedYear
        settings.targetMonth = months[selectedMonth] ?? ""

        viewModel.publishVacationSettings(settings)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            dismiss()
        }
    }
}

#Preview {
    VacationSettingsView(viewModel: BossMainViewModel())
}
