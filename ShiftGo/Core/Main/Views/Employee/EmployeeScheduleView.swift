//
//  EmployeeScheduleView.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/8/27.
//

import SwiftUI

struct EmployeeScheduleView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var isPresented: Bool
    @ObservedObject var controller: CalendarController

    @State private var selectedVacationDates: Set<YearMonthDay> = []
    @State private var isPickerPresented = false
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""

    // 排休限制
    private let maxVacationDaysPerMonth = 8
    private let maxVacationDaysPerWeek = 2

    var body: some View {
        NavigationView {
            GeometryReader { reader in
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header Section
                        headerSection()

                        // Stats Cards
                        statsSection()

                        // Month Selector
                        monthSelectorSection()

                        // Calendar Section
                        calendarSection()

                        // Action Buttons
                        actionButtonsSection()
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 30)
                }
                .background(AppColors.Background.primary(colorScheme))
            }
            .navigationTitle("排休設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        isPresented = false
                    }
                    .foregroundColor(AppColors.Text.header(colorScheme))
                }
            }
        }
        .alert("提示", isPresented: $showingAlert) {
            Button("確定") { }
        } message: {
            Text(alertMessage)
        }
    }

    // MARK: - Header Section
    private func headerSection() -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "calendar.badge.checkmark")
                    .font(.system(size: 32))
                    .foregroundColor(AppColors.Calendar.saturday)

                VStack(alignment: .leading, spacing: 4) {
                    Text("排休申請")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppColors.Text.header(colorScheme))

                    Text("選擇您希望的休假日期")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.7))
                }

                Spacer()
            }
        }
        .padding(.vertical, 12)
    }

    // MARK: - Stats Section
    private func statsSection() -> some View {
        HStack(spacing: 12) {
            // 月限制
            statsCard(
                title: "月上限",
                value: "\(maxVacationDaysPerMonth)",
                color: AppColors.Calendar.saturday,
                subtitle: "天/月"
            )

            // 週限制
            statsCard(
                title: "週上限",
                value: "\(maxVacationDaysPerWeek)",
                color: AppColors.Calendar.sunday,
                subtitle: "天/週"
            )

            // 已選擇
            statsCard(
                title: "已選擇",
                value: "\(selectedVacationDates.count)",
                color: .orange,
                subtitle: "天"
            )
        }
    }

    private func statsCard(title: String, value: String, color: Color, subtitle: String) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.7))

            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(color)

            Text(subtitle)
                .font(.system(size: 10))
                .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.5))
        }
        .frame(minWidth: 80, maxWidth: .infinity, minHeight: 80)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.Background.primary(colorScheme))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppColors.Text.header(colorScheme).opacity(0.1), lineWidth: 1)
                )
        )
    }

    // MARK: - Month Selector Section
    private func monthSelectorSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("選擇月份")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppColors.Text.header(colorScheme))

            Button(action: {
                selectedMonth = controller.yearMonth.month
                selectedYear = controller.yearMonth.year
                isPickerPresented = true
            }) {
                HStack {
                    HStack(spacing: 8) {
                        Text("\(controller.yearMonth.monthString)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(AppColors.Text.header(colorScheme))

                        Text("\(String(controller.yearMonth.year))")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.8))
                    }

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.6))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(AppColors.Background.primary(colorScheme))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(AppColors.Text.header(colorScheme).opacity(0.2), lineWidth: 1)
                        )
                )
            }
        }
    }

    // MARK: - Calendar Section
    private func calendarSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("選擇休假日期")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppColors.Text.header(colorScheme))

            VStack(spacing: 0) {
                // 使用與 EmployeeMainView 相同的 CalendarView
                CalendarView(controller, header: { week in
                    Text(week.shortString)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.7))
                        .frame(maxWidth: .infinity, minHeight: 30)
                }, component: { date in
                    Button(action: {
                        if date.isFocusYearMonth == true {
                            toggleVacationDate(date)
                        }
                    }) {
                        ZStack {
                            // 背景
                            RoundedRectangle(cornerRadius: 8)
                                .fill(getDateBackgroundColor(date))
                                .frame(minWidth: 40, minHeight: 40)

                            VStack(spacing: 2) {
                                Text("\(date.day)")
                                    .font(.system(size: 14, weight: selectedVacationDates.contains(date) ? .bold : .medium))
                                    .foregroundColor(getDateTextColor(date))

                                if selectedVacationDates.contains(date) {
                                    Text("休")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 1)
                                        .background(Color.orange.opacity(0.8))
                                        .cornerRadius(2)
                                }
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(date.isFocusYearMonth == false)
                })
                .frame(minHeight: 300) // 給日曆一個最小高度
                .sheet(isPresented: $isPickerPresented) {
                    MonthPickerSheet(selectedYear: $selectedYear, selectedMonth: $selectedMonth, isPresented: $isPickerPresented, controller: controller)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.Background.primary(colorScheme))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppColors.Text.header(colorScheme).opacity(0.1), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 8)
            .padding(.vertical, 12)
        }
    }

    // MARK: - Action Buttons Section
    private func actionButtonsSection() -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // 清除按鈕
                Button("清除全部") {
                    selectedVacationDates.removeAll()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppColors.Calendar.sunday.opacity(0.1))
                )
                .foregroundColor(AppColors.Calendar.sunday)
                .font(.system(size: 16, weight: .semibold))

                // 提交按鈕
                Button(isLoading ? "提交中..." : "提交排休") {
                    submitVacationRequest()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(selectedVacationDates.isEmpty ? Color.gray.opacity(0.3) : AppColors.Calendar.saturday)
                )
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .semibold))
                .disabled(selectedVacationDates.isEmpty || isLoading)
            }
        }
    }

    // MARK: - Helper Methods
    private func getDateBackgroundColor(_ date: YearMonthDay) -> Color {
        if selectedVacationDates.contains(date) {
            return .orange.opacity(0.8)
        } else if date.isFocusYearMonth == true {
            return AppColors.Background.primary(colorScheme).opacity(0.1)
        } else {
            return Color.clear
        }
    }

    private func getDateTextColor(_ date: YearMonthDay) -> Color {
        if selectedVacationDates.contains(date) {
            return .white
        } else if date.isFocusYearMonth == false {
            return AppColors.Text.header(colorScheme).opacity(0.3)
        } else {
            switch date.dayOfWeek {
            case .sun:
                return AppColors.Calendar.sunday
            case .sat:
                return AppColors.Calendar.saturday
            default:
                return AppColors.Calendar.dayText(colorScheme)
            }
        }
    }

    private func toggleVacationDate(_ date: YearMonthDay) {
        if selectedVacationDates.contains(date) {
            selectedVacationDates.remove(date)
        } else {
            // 檢查是否超過月限制
            if selectedVacationDates.count >= maxVacationDaysPerMonth {
                alertMessage = "每月最多只能申請 \(maxVacationDaysPerMonth) 天排休"
                showingAlert = true
                return
            }

            // 檢查週限制 (這裡簡化處理，實際應該檢查同一週的日期)
            selectedVacationDates.insert(date)
        }
    }

    private func submitVacationRequest() {
        guard !selectedVacationDates.isEmpty else { return }

        isLoading = true

        // 模擬提交請求
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            alertMessage = "排休申請已提交，等待主管審核"
            showingAlert = true

            // 提交成功後關閉畫面
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                isPresented = false
            }
        }
    }
}

#Preview {
    EmployeeScheduleView(
        isPresented: .constant(true),
        controller: CalendarController(orientation: .horizontal)
    )
    .environmentObject(ThemeManager())
}
