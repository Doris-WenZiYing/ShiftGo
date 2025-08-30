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

    @StateObject private var viewModel = EmployeeMainViewModel()
    @State private var isPickerPresented = false
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())

    var body: some View {
        NavigationView {
            GeometryReader { reader in
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header Section
                        headerSection()

                        // Status Section
                        statusSection()

                        // Stats Cards (only show if vacation is published)
                        if viewModel.isVacationPublished {
                            statsSection()
                        }

                        // Month Selector
                        monthSelectorSection()

                        // Calendar Section (only show if vacation is published)
                        if viewModel.isVacationPublished {
                            calendarSection()
                        }

                        // Action Buttons (only show if vacation is published and no existing request)
                        if viewModel.isVacationPublished && !viewModel.hasExistingRequest(for: controller.yearMonth.year, month: controller.yearMonth.month) {
                            actionButtonsSection()
                        }

                        // Existing Request Info
                        if viewModel.hasExistingRequest(for: controller.yearMonth.year, month: controller.yearMonth.month) {
                            existingRequestSection()
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 30)
                }
                .background(AppColors.Background.primary(colorScheme))
            }
            .navigationTitle("排休申請")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("關閉") {
                        isPresented = false
                    }
                    .foregroundColor(AppColors.Text.header(colorScheme))
                }
            }
        }
        .onAppear {
            viewModel.loadData(for: controller.yearMonth.year, month: controller.yearMonth.month)
        }
        .onChange(of: controller.yearMonth) { _, newYearMonth in
            viewModel.loadData(for: newYearMonth.year, month: newYearMonth.month)
        }
        .overlay(
            // Toast
            toastOverlay()
        )
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

                    Text(viewModel.isVacationPublished ? "選擇您希望的休假日期" : "等待主管開放排休")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.7))
                }

                Spacer()

                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.Calendar.saturday))
                        .scaleEffect(0.8)
                }
            }
        }
        .padding(.vertical, 12)
    }

    // MARK: - Status Section
    private func statusSection() -> some View {
        let status = viewModel.getVacationStatus(for: controller.yearMonth.year, month: controller.yearMonth.month)

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: status.icon)
                    .font(.system(size: 16))
                    .foregroundColor(status.color)

                Text("申請狀態：\(status.displayText)")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(status.color)

                Spacer()
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(status.color.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(status.color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }

    // MARK: - Stats Section
    private func statsSection() -> some View {
        let stats = viewModel.getVacationStats(for: controller.yearMonth.year, month: controller.yearMonth.month)

        return HStack(spacing: 12) {
            // 月上限
            statsCard(
                title: "月上限",
                value: "\(stats.maxDays)",
                color: AppColors.Calendar.saturday,
                subtitle: "天/月"
            )

            // 週上限
            statsCard(
                title: "週上限",
                value: "\(stats.maxWeeklyDays)",
                color: AppColors.Calendar.sunday,
                subtitle: "天/週"
            )

            // 已選擇
            statsCard(
                title: "已選擇",
                value: "\(stats.selectedDays)",
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
            .sheet(isPresented: $isPickerPresented) {
                MonthPickerSheet(selectedYear: $selectedYear, selectedMonth: $selectedMonth, isPresented: $isPickerPresented, controller: controller)
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
                CalendarView(controller, header: { week in
                    Text(week.shortString)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.7))
                        .frame(maxWidth: .infinity, minHeight: 30)
                }, component: { date in
                    Button(action: {
                        if date.isFocusYearMonth == true {
                            viewModel.toggleDateSelection(date)
                        }
                    }) {
                        ZStack {
                            // 背景
                            RoundedRectangle(cornerRadius: 8)
                                .fill(getDateBackgroundColor(date))
                                .frame(minWidth: 40, minHeight: 40)

                            VStack(spacing: 2) {
                                Text("\(date.day)")
                                    .font(.system(size: 14, weight: viewModel.selectedVacationDates.contains(date) ? .bold : .medium))
                                    .foregroundColor(getDateTextColor(date))

                                if viewModel.selectedVacationDates.contains(date) {
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
                .frame(minHeight: 300)
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

            // Note input
            VStack(alignment: .leading, spacing: 8) {
                Text("備註（選填）")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppColors.Text.header(colorScheme))

                TextField("請輸入排休原因...", text: $viewModel.vacationNote, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(3, reservesSpace: true)
            }
        }
    }

    // MARK: - Action Buttons Section
    private func actionButtonsSection() -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // 清除按鈕
                Button("清除全部") {
                    viewModel.clearSelectedDates()
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
                Button(viewModel.isLoading ? "提交中..." : "提交排休") {
                    viewModel.submitVacationRequest(for: controller.yearMonth.year, month: controller.yearMonth.month)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(viewModel.canSubmitVacation(for: controller.yearMonth.year, month: controller.yearMonth.month) ? AppColors.Calendar.saturday : Color.gray.opacity(0.3))
                )
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .semibold))
                .disabled(!viewModel.canSubmitVacation(for: controller.yearMonth.year, month: controller.yearMonth.month) || viewModel.isLoading)
            }
        }
    }

    // MARK: - Existing Request Section
    private func existingRequestSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("已提交的申請")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppColors.Text.header(colorScheme))

            ForEach(viewModel.myVacationRequests.filter { vacation in
                vacation.dates.contains { dateString in
                    let components = dateString.split(separator: "-")
                    guard components.count == 3,
                          let year = Int(components[0]),
                          let month = Int(components[1]) else {
                        return false
                    }
                    return year == controller.yearMonth.year && month == controller.yearMonth.month
                }
            }, id: \.id) { vacation in
                existingRequestCard(vacation)
            }
        }
    }

    private func existingRequestCard(_ vacation: EmployeeVacation) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("申請日期")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppColors.Text.header(colorScheme))

                Spacer()

                Text(vacation.status.displayText)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(vacation.status.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(vacation.status.color.opacity(0.1))
                    )
            }

            // 顯示申請的日期
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 4) {
                ForEach(Array(vacation.dates.sorted()), id: \.self) { dateString in
                    if let date = parseDateString(dateString) {
                        Text("\(date.day)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 30, height: 30)
                            .background(Circle().fill(vacation.status.color))
                    }
                }
            }

            if !vacation.note.isEmpty {
                Text("備註：\(vacation.note)")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.7))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.Background.primary(colorScheme))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(vacation.status.color.opacity(0.3), lineWidth: 1)
                )
        )
    }

    // MARK: - Toast Overlay
    private func toastOverlay() -> some View {
        VStack {
            if viewModel.showingToast {
                VStack {
                    Spacer()

                    HStack(spacing: 12) {
                        Image(systemName: viewModel.toastType.icon)
                            .foregroundColor(viewModel.toastType.color)

                        Text(viewModel.toastMessage)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppColors.Text.header(colorScheme))

                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 100)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .allowsHitTesting(false)
    }

    // MARK: - Helper Methods
    private func getDateBackgroundColor(_ date: YearMonthDay) -> Color {
        if viewModel.selectedVacationDates.contains(date) {
            return .orange.opacity(0.8)
        } else if date.isFocusYearMonth == true {
            return AppColors.Background.primary(colorScheme).opacity(0.1)
        } else {
            return Color.clear
        }
    }

    private func getDateTextColor(_ date: YearMonthDay) -> Color {
        if viewModel.selectedVacationDates.contains(date) {
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

    private func parseDateString(_ dateString: String) -> YearMonthDay? {
        let components = dateString.split(separator: "-")
        guard components.count == 3,
              let year = Int(components[0]),
              let month = Int(components[1]),
              let day = Int(components[2]) else {
            return nil
        }
        return YearMonthDay(year: year, month: month, day: day)
    }
}

#Preview {
    EmployeeScheduleView(
        isPresented: .constant(true),
        controller: CalendarController(orientation: .horizontal)
    )
    .environmentObject(ThemeManager())
}
