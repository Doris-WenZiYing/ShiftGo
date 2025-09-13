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
    @State private var validator: VacationValidator?

    var body: some View {
        NavigationView {
            GeometryReader { reader in
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        headerSection()
                        statusSection()

                        if viewModel.isVacationPublished {
                            statsSection()
                            monthSelectorSection()
                            calendarSection()

                            if !viewModel.hasExistingRequest(for: controller.yearMonth.year, month: controller.yearMonth.month) {
                                actionButtonsSection()
                            }
                        }

                        if viewModel.hasExistingRequest(for: controller.yearMonth.year, month: controller.yearMonth.month) {
                            existingRequestSection()
                        }
                    }
                    .padding(.horizontal, 20)
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
                    .foregroundColor(.blue)
                }
            }
        }
        .onAppear {
            viewModel.loadData(for: controller.yearMonth.year, month: controller.yearMonth.month)
        }
        .onChange(of: controller.yearMonth) { _, newYearMonth in
            viewModel.loadData(for: newYearMonth.year, month: newYearMonth.month)
        }
        .onChange(of: viewModel.vacationSettings) { _, newSettings in
            if let settings = newSettings {
                validator = VacationValidator(settings: settings)
            }
        }
        .overlay(
            toastOverlay()
        )
    }

    // MARK: - Header Section
    private func headerSection() -> some View {
        VStack(spacing: 16) {
            // Icon and Title
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [
                                AppColors.Calendar.saturday,
                                .blue
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 80, height: 80)

                    Image(systemName: "calendar.badge.checkmark")
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundColor(.white)
                }

                VStack(spacing: 6) {
                    Text("排休申請")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(AppColors.Text.header(colorScheme))

                    Text(viewModel.isVacationPublished ? "選擇您希望的休假日期" : "等待主管開放排休")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.7))
                        .multilineTextAlignment(.center)
                }
            }

            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: AppColors.Calendar.saturday))
                    .scaleEffect(0.8)
            }
        }
    }

    // MARK: - Status Section
    private func statusSection() -> some View {
        let status = viewModel.getVacationStatus(for: controller.yearMonth.year, month: controller.yearMonth.month)

        return VStack(alignment: .leading, spacing: 16) {
            HStack {
                Circle()
                    .fill(status.color)
                    .frame(width: 12, height: 12)

                Text("申請狀態")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.Text.header(colorScheme))

                Spacer()
            }

            HStack(spacing: 12) {
                Image(systemName: status.icon)
                    .font(.system(size: 24))
                    .foregroundColor(status.color)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(status.color.opacity(0.1))
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(status.displayText)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(status.color)

                    Text(getStatusDescription(status))
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.7))
                }

                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(status.color.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(status.color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }

    // MARK: - Stats Section
    private func statsSection() -> some View {
        guard let settings = viewModel.vacationSettings else { return AnyView(EmptyView()) }

        let stats = VacationStatsHelper.getStats(
            selectedDates: viewModel.selectedVacationDates,
            settings: settings,
            targetYear: controller.yearMonth.year,
            targetMonth: controller.yearMonth.month
        )

        return AnyView(
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.blue)

                    Text("排休統計")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.Text.header(colorScheme))

                    Spacer()
                }

                HStack(spacing: 12) {
                    // 已選擇天數
                    statsCard(
                        title: "已選擇",
                        value: "\(stats.selectedDays)",
                        subtitle: "天",
                        color: .blue,
                        progress: nil
                    )

                    // 月限制統計
                    if settings.hasMonthlyLimit, let monthlyLimit = stats.monthlyLimit {
                        statsCard(
                            title: "月限制",
                            value: "\(stats.selectedDays)/\(monthlyLimit)",
                            subtitle: "天",
                            color: .orange,
                            progress: stats.monthlyUsagePercentage
                        )
                    }

                    // 週限制統計
                    if settings.hasWeeklyLimit, let weeklyLimit = stats.weeklyLimit {
                        statsCard(
                            title: "週限制",
                            value: "\(stats.maxWeeklyUsed)/\(weeklyLimit)",
                            subtitle: "天",
                            color: .purple,
                            progress: stats.weeklyUsagePercentage
                        )
                    }
                }

                // 限制說明
                if settings.hasMonthlyLimit || settings.hasWeeklyLimit {
                    HStack {
                        Image(systemName: "info.circle")
                            .font(.system(size: 14))
                            .foregroundColor(.blue)

                        Text(settings.limitDescription)
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.7))

                        Spacer()
                    }
                    .padding(.horizontal, 4)
                }
            }
        )
    }

    private func statsCard(title: String, value: String, subtitle: String, color: Color, progress: Double?) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.7))

            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(color)

            Text(subtitle)
                .font(.system(size: 10))
                .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.5))

            // Progress bar
            if let progress = progress {
                VStack(spacing: 4) {
                    ProgressView(value: progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: color))
                        .scaleEffect(y: 2)

                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(color)
                }
            }
        }
        .frame(minWidth: 80, maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
    }

    // MARK: - Month Selector Section
    private func monthSelectorSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "calendar")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.blue)

                Text("選擇月份")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.Text.header(colorScheme))

                Spacer()
            }

            Button(action: {
                selectedMonth = controller.yearMonth.month
                selectedYear = controller.yearMonth.year
                isPickerPresented = true
            }) {
                HStack {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [.blue, .green]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text("\(controller.yearMonth.month)")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                            )

                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(controller.yearMonth.monthString)")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(AppColors.Text.header(colorScheme))

                            Text("\(String(controller.yearMonth.year))")
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.7))
                        }
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.6))
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(AppColors.Background.primary(colorScheme))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppColors.Text.header(colorScheme).opacity(0.1), lineWidth: 1)
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
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.green)

                Text("選擇休假日期")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.Text.header(colorScheme))

                Spacer()
            }

            VStack(spacing: 16) {
                CalendarView(controller, header: { week in
                    Text(week.shortString)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.8))
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(AppColors.Background.primary(colorScheme).opacity(0.5))
                        )
                }, component: { date in
                    dateCell(date)
                })
                .frame(minHeight: 320)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(AppColors.Background.primary(colorScheme))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppColors.Text.header(colorScheme).opacity(0.1), lineWidth: 1)
                        )
                )

                // Note input
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "note.text")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)

                        Text("備註（選填）")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppColors.Text.header(colorScheme))
                    }

                    TextField("請輸入排休原因...", text: $viewModel.vacationNote, axis: .vertical)
                        .font(.system(size: 16))
                        .lineLimit(3, reservesSpace: true)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(AppColors.Background.primary(colorScheme))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(AppColors.Text.header(colorScheme).opacity(0.2), lineWidth: 1)
                                )
                        )
                }
            }
        }
    }

    private func dateCell(_ date: YearMonthDay) -> some View {
        Button(action: {
            if date.isFocusYearMonth == true {
                handleDateTap(date)
            }
        }) {
            ZStack {
                let isSelected = viewModel.selectedVacationDates.contains(date)
                let canSelect = validator?.canSelectDate(date, currentSelection: viewModel.selectedVacationDates) ?? true
                let isCurrentMonth = date.isFocusYearMonth == true

                RoundedRectangle(cornerRadius: 12)
                    .fill(getDateBackgroundColor(date, isSelected: isSelected, canSelect: canSelect))
                    .frame(minWidth: 44, minHeight: 44)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(getDateBorderColor(date, isSelected: isSelected), lineWidth: isSelected ? 2 : 0)
                    )

                VStack(spacing: 4) {
                    Text("\(date.day)")
                        .font(.system(size: 16, weight: isSelected ? .bold : .medium))
                        .foregroundColor(getDateTextColor(date, isSelected: isSelected, canSelect: canSelect))

                    if isSelected {
                        Circle()
                            .fill(.white)
                            .frame(width: 6, height: 6)
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(date.isFocusYearMonth == false)
        .scaleEffect(viewModel.selectedVacationDates.contains(date) ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: viewModel.selectedVacationDates.contains(date))
    }

    // MARK: - Action Buttons Section
    private func actionButtonsSection() -> some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                // Clear button
                Button("清除全部") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        viewModel.clearSelectedDates()
                    }
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.red.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                        )
                )
                .disabled(viewModel.selectedVacationDates.isEmpty)
                .opacity(viewModel.selectedVacationDates.isEmpty ? 0.5 : 1.0)

                // Submit button
                Button(viewModel.isLoading ? "提交中..." : "提交排休") {
                    viewModel.submitVacationRequest(for: controller.yearMonth.year, month: controller.yearMonth.month)
                }
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            isSubmitEnabled ? .green : .gray,
                            isSubmitEnabled ? .blue : .gray.opacity(0.8)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .shadow(
                    color: isSubmitEnabled ? .green.opacity(0.3) : .clear,
                    radius: 6,
                    x: 0,
                    y: 3
                )
                .disabled(!isSubmitEnabled || viewModel.isLoading)
                .scaleEffect(viewModel.isLoading ? 0.98 : 1.0)
            }
        }
    }

    // MARK: - Existing Request Section
    private func existingRequestSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.green)

                Text("已提交的申請")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.Text.header(colorScheme))

                Spacer()
            }

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
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: vacation.status.displayText)
                    .font(.system(size: 20))
                    .foregroundColor(vacation.status.color)

                VStack(alignment: .leading, spacing: 4) {
                    Text("申請狀態")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.7))

                    Text(vacation.status.displayText)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(vacation.status.color)
                }

                Spacer()

                Text(formatSubmitDate(vacation.submitDate))
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.6))
            }

            // Display vacation dates
            let dates = vacation.dates.compactMap(parseDateString).sorted { $0.day < $1.day }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(dates, id: \.self) { date in
                    Text("\(date.day)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(vacation.status.color)
                        )
                }
            }

            if !vacation.note.isEmpty {
                HStack {
                    Image(systemName: "note.text")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)

                    Text(vacation.note)
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.8))
                }
                .padding(.top, 4)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(vacation.status.color.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
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
    private func handleDateTap(_ date: YearMonthDay) {
        guard let validator = validator else {
            viewModel.toggleDateSelection(date)
            return
        }

        // Check if we can select this date
        if validator.canSelectDate(date, currentSelection: viewModel.selectedVacationDates) {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.toggleDateSelection(date)
            }
        } else {
            // Show validation error
            let newSelection = viewModel.selectedVacationDates.union([date])
            let result = validator.validate(selectedDates: newSelection, targetYear: date.year, targetMonth: date.month)

            if let errorMessage = result.errorMessage {
                viewModel.toastMessage = errorMessage
                viewModel.toastType = .error
                viewModel.showingToast = true

                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    viewModel.showingToast = false
                }
            }
        }
    }

    private func getDateBackgroundColor(_ date: YearMonthDay, isSelected: Bool, canSelect: Bool) -> Color {
        if isSelected {
            return Color.green
        } else if date.isFocusYearMonth == true && canSelect {
            return AppColors.Background.primary(colorScheme).opacity(0.1)
        } else {
            return Color.clear
        }
    }

    private func getDateBorderColor(_ date: YearMonthDay, isSelected: Bool) -> Color {
        if isSelected {
            return .white
        }
        return Color.clear
    }

    private func getDateTextColor(_ date: YearMonthDay, isSelected: Bool, canSelect: Bool) -> Color {
        if isSelected {
            return .white
        } else if date.isFocusYearMonth == false {
            return AppColors.Text.header(colorScheme).opacity(0.3)
        } else if !canSelect {
            return AppColors.Text.header(colorScheme).opacity(0.4)
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

    private var isSubmitEnabled: Bool {
        viewModel.canSubmitVacation(for: controller.yearMonth.year, month: controller.yearMonth.month) &&
        !viewModel.selectedVacationDates.isEmpty &&
        !viewModel.isLoading
    }

    private func getStatusDescription(_ status: EmployeeVacationStatus) -> String {
        switch status {
        case .notSubmitted:
            return viewModel.isVacationPublished ? "可以開始選擇排休日期" : "請等待主管開放排休申請"
        case .pending:
            return "申請已送出，等待主管審核"
        case .approved:
            return "申請已通過，排休生效"
        case .rejected:
            return "申請被拒絕，可重新申請"
        case .expired:
            return "申請已過期"
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

    private func formatSubmitDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
    EmployeeScheduleView(
        isPresented: .constant(true),
        controller: CalendarController(orientation: .horizontal)
    )
    .environmentObject(ThemeManager())
}
