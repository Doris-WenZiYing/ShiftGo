//
//  BossMainView.swift (Fixed Multiple Sheets Issue)
//  ShiftGo
//
//  Created by Doris Wen on 2025/8/25.
//

import SwiftUI

// MARK: - Sheet Type Enum
enum BossSheetType {
    case management
    case vacationSettings
    case scheduleGeneration
    case scheduleView
}

struct BossMainView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var controller: CalendarController = CalendarController(orientation: .horizontal)
    @State var focusDate: YearMonthDay? = YearMonthDay.current

    // ViewModel
    @StateObject private var viewModel = BossMainViewModel()

    @State private var isPickerPresented = false
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var selectedDate = Date()

    // Unified Sheet Management
    @State private var currentSheet: BossSheetType?
    @State private var selectedAction: BossAction?

    var body: some View {
        GeometryReader { reader in
            ZStack {
                VStack(alignment: .leading, spacing: 0) {
                    // Month selector with status
                    monthSelectorSection()

                    // Calendar view
                    calendarSection()
                }
                .background(AppColors.Background.primary(colorScheme))

                // Selected date information
                VStack {
                    Spacer()

                    if (viewModel.selectedDate != nil),
                       !viewModel.selectedDateVacations.isEmpty {
                        selectedDateInfoSection()
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }

                // Toast
                if viewModel.showingToast {
                    toastView()
                }
            }
        }
        .sheet(item: Binding<BossSheetType?>(
            get: { currentSheet },
            set: { currentSheet = $0 }
        )) { sheetType in
            sheetContent(for: sheetType)
        }
        .onChange(of: selectedAction) { _, action in
            handleSelectedAction(action)
        }
    }

    // MARK: - Sheet Content
    @ViewBuilder
    private func sheetContent(for sheetType: BossSheetType) -> some View {
        switch sheetType {
        case .management:
            BossManagementSheet(
                isPresented: Binding(
                    get: { currentSheet == .management },
                    set: { _ in currentSheet = nil }
                ),
                selectedAction: $selectedAction,
                isVacationPublished: .constant(viewModel.isVacationPublished),
                employeeVacationCount: .constant(viewModel.employeeVacationCount),
                isLoading: .constant(viewModel.isLoading)
            )
            .environmentObject(themeManager)
            .presentationDetents([.fraction(0.6), .large])

        case .vacationSettings:
            VacationSettingsView(viewModel: viewModel)
                .environmentObject(themeManager)

        case .scheduleGeneration:
            Text("班表生成界面")
                .font(.title)
                .foregroundColor(AppColors.Text.header(colorScheme))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(AppColors.Background.primary(colorScheme))

        case .scheduleView:
            Text("班表查看界面")
                .font(.title)
                .foregroundColor(AppColors.Text.header(colorScheme))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(AppColors.Background.primary(colorScheme))
        }
    }

    // MARK: - Month Selector Section
    private func monthSelectorSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Button(action: {
                    selectedMonth = controller.yearMonth.month
                    selectedYear = controller.yearMonth.year
                    isPickerPresented = true
                }) {
                    HStack(spacing: 8) {
                        Text("\(controller.yearMonth.monthString)")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(AppColors.Text.header(colorScheme))

                        Text("\(String(controller.yearMonth.year))")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.9))

                        Image(systemName: "chevron.down")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.7))
                    }
                }
                .padding(.leading, 10)
                .sheet(isPresented: $isPickerPresented) {
                    MonthPickerSheet(selectedYear: $selectedYear, selectedMonth: $selectedMonth, isPresented: $isPickerPresented, controller: controller)
                }

                Spacer()

                // Management button moved to top right
                Button(action: {
                    currentSheet = .management
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.yellow)

                        Text("管理")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppColors.Text.header(colorScheme))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(AppColors.Background.primary(colorScheme))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(AppColors.Text.header(colorScheme).opacity(0.2), lineWidth: 1)
                            )
                    )
                }
                .disabled(viewModel.isLoading)
                .opacity(viewModel.isLoading ? 0.6 : 1.0)
                .padding(.trailing, 16)
            }

            // Status indicators
            HStack(spacing: 8) {
                statusIndicators()
                Spacer()
            }
            .padding(.horizontal, 16)

            // Statistics
            if viewModel.isVacationPublished {
                monthlyStatsSection()
                    .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 12)
    }

    private func statusIndicators() -> some View {
        HStack(spacing: 8) {
            // Vacation status
            HStack(spacing: 6) {
                Circle()
                    .fill(viewModel.isVacationPublished ? Color.green : Color.orange)
                    .frame(width: 8, height: 8)

                Text(viewModel.isVacationPublished ? "已開放" : "未開放")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(viewModel.isVacationPublished ? .green : .orange)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill((viewModel.isVacationPublished ? Color.green : Color.orange).opacity(0.1))
            )

            // Employee count (if published)
            if viewModel.isVacationPublished && viewModel.employeeVacationCount > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.blue)

                    Text("\(viewModel.employeeVacationCount)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.blue)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue.opacity(0.1))
                )
            }
        }
    }

    private func monthlyStatsSection() -> some View {
        let stats = viewModel.getMonthlyStats(
            for: controller.yearMonth.year,
            month: controller.yearMonth.month
        )

        return HStack(spacing: 16) {
            statItem(title: "申請員工", value: "\(stats.totalEmployees)人", color: .blue)
            statItem(title: "總休假", value: "\(stats.totalDays)天", color: .orange)
            if stats.pendingRequests > 0 {
                statItem(title: "待審核", value: "\(stats.pendingRequests)", color: .red)
            }
        }
        .padding(.top, 8)
    }

    private func statItem(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(color)

            Text(title)
                .font(.system(size: 10))
                .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.6))
        }
    }

    // MARK: - Calendar Section
    private func calendarSection() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            CalendarView(controller, header: { week in
                GeometryReader { geometry in
                    Text(week.shortString)
                        .font(.subheadline)
                        .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                }
            }, component: { date in
                GeometryReader { geometry in
                    VStack(spacing: 2) {
                        // Day number
                        Text("\(date.day)")
                            .font(.system(
                                size: 14,
                                weight: focusDate == date ? .bold : .light,
                                design: .default
                            ))
                            .opacity(date.isFocusYearMonth == true ? 1 : 0.4)
                            .foregroundColor(date.dayColor(for: colorScheme))
                            .frame(height: 20)
                            .padding(.top, 4)

                        // Vacation indicators
                        let matchingVacations = viewModel.employeeVacations.filter { vacation in
                            vacation.dates.contains { dateString in
                                let components = dateString.split(separator: "-")
                                guard components.count == 3,
                                      let year = Int(components[0]),
                                      let month = Int(components[1]),
                                      let day = Int(components[2]) else {
                                    return false
                                }
                                return year == date.year && month == date.month && day == date.day
                            }
                        }

                        if !matchingVacations.isEmpty {
                            VStack(spacing: 2) {
                                ForEach(Array(matchingVacations.prefix(3).enumerated()), id: \.offset) { index, vacation in
                                    Rectangle()
                                        .fill(getEmployeeColor(vacation.employeeName))
                                        .frame(width: geometry.size.width - 8, height: 4)
                                        .cornerRadius(2)
                                        .opacity(date.isFocusYearMonth == true ? 1 : 0.4)
                                }

                                if matchingVacations.count > 3 {
                                    Text("···")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundColor(.gray)
                                        .opacity(date.isFocusYearMonth == true ? 1 : 0.4)
                                }
                            }
                            .padding(.top, 2)
                        }

                        Spacer()
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                    .background(
                        viewModel.selectedDate == date ? Color.gray.opacity(0.15) :
                        (focusDate == date ? Color.gray.opacity(0.15) : Color.clear)
                    )
                    .cornerRadius(2)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            focusDate = (focusDate != date ? date : nil)
                            viewModel.selectDate(date)
                        }
                    }
                }
            })
        }
    }

    // MARK: - Selected Date Info Section
    private func selectedDateInfoSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar.badge.checkmark")
                    .font(.system(size: 16))
                    .foregroundColor(.green)

                if let selectedDate = viewModel.selectedDate {
                    Text("\(String(selectedDate.year))年\(selectedDate.month)月\(selectedDate.day)日 排休詳情")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.Text.header(colorScheme))
                }

                Spacer()

                Button("關閉") {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.selectDate(viewModel.selectedDate!)
                        focusDate = nil
                    }
                }
                .font(.system(size: 14))
                .foregroundColor(.blue)
            }

            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.selectedDateVacations) { vacation in
                        vacationDetailCard(vacation)
                    }
                }
            }
            .frame(maxHeight: 200)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.Background.blackBg(colorScheme))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 0.5)
                )
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }

    private func vacationDetailCard(_ vacation: EmployeeVacation) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(getEmployeeColor(vacation.employeeName))
                .frame(width: 12, height: 12)

            VStack(alignment: .leading, spacing: 4) {
                Text(vacation.employeeName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.Text.header(colorScheme))

                if !vacation.note.isEmpty {
                    Text(vacation.note)
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.7))
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                statusBadge(vacation.status)

                if vacation.status == .pending {
                    HStack(spacing: 8) {
                        Button(action: {
                            viewModel.approveVacation(vacation.id)
                        }) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.green)
                        }

                        Button(action: {
                            viewModel.rejectVacation(vacation.id)
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(AppColors.Background.primary(colorScheme))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(getEmployeeColor(vacation.employeeName).opacity(0.3), lineWidth: 1)
                )
        )
    }

    private func statusBadge(_ status: EmployeeVacation.VacationRequestStatus) -> some View {
        let (text, color) = getStatusInfo(status)

        return Text(text)
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(color.opacity(0.1))
            )
    }

    // MARK: - Toast View
    private func toastView() -> some View {
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

    // MARK: - Action Handling
    private func handleSelectedAction(_ action: BossAction?) {
        guard let action = action else { return }

        // 延遲一點以確保當前 sheet 狀態穩定
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            switch action {
            case .publishVacation, .manageVacationLimits:
                // 關閉管理 sheet 後開啟排休設定 sheet
                currentSheet = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    currentSheet = .vacationSettings
                }
            case .unpublishVacation:
                viewModel.unpublishVacation()
                currentSheet = nil
            case .generateSchedule:
                currentSheet = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    currentSheet = .scheduleGeneration
                }
            case .viewSchedule:
                currentSheet = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    currentSheet = .scheduleView
                }
            default:
                currentSheet = nil
            }

            // Reset selection
            selectedAction = nil
        }
    }

    // MARK: - Helper Methods
    private func getEmployeeColor(_ employeeName: String) -> Color {
        let colors: [Color] = [
            .blue, .orange, .green, .purple,
            .pink, .red, .teal, .indigo,
            .yellow, .cyan
        ]
        let hash = abs(employeeName.hashValue)
        return colors[hash % colors.count]
    }

    private func getStatusInfo(_ status: EmployeeVacation.VacationRequestStatus) -> (String, Color) {
        switch status {
        case .pending:
            return ("待審核", .orange)
        case .approved:
            return ("已核准", .green)
        case .rejected:
            return ("已拒絕", .red)
        }
    }
}

extension BossSheetType: Identifiable {
    var id: String {
        switch self {
        case .management: return "management"
        case .vacationSettings: return "vacationSettings"
        case .scheduleGeneration: return "scheduleGeneration"
        case .scheduleView: return "scheduleView"
        }
    }
}

// MARK: - Boss Actions Enum (same as before)
enum BossAction: String, CaseIterable {
    case publishVacation = "發佈排休"
    case unpublishVacation = "取消發佈"
    case manageVacationLimits = "排休設定"
    case generateSchedule = "生成班表"
    case viewSchedule = "查看班表"
    case employeeManagement = "員工管理"

    var icon: String {
        switch self {
        case .publishVacation:
            return "calendar.badge.plus"
        case .unpublishVacation:
            return "calendar.badge.minus"
        case .manageVacationLimits:
            return "gear"
        case .generateSchedule:
            return "calendar.badge.clock"
        case .viewSchedule:
            return "calendar"
        case .employeeManagement:
            return "person.3"
        }
    }

    var color: Color {
        switch self {
        case .publishVacation:
            return .green
        case .unpublishVacation:
            return .red
        case .manageVacationLimits:
            return .blue
        case .generateSchedule:
            return .orange
        case .viewSchedule:
            return .purple
        case .employeeManagement:
            return .cyan
        }
    }

    var description: String {
        switch self {
        case .publishVacation:
            return "開放員工進行排休申請"
        case .unpublishVacation:
            return "關閉排休申請功能"
        case .manageVacationLimits:
            return "設定排休規則和限制"
        case .generateSchedule:
            return "根據排休生成工作班表"
        case .viewSchedule:
            return "查看當前工作班表"
        case .employeeManagement:
            return "管理員工資訊"
        }
    }
}

#Preview {
    BossMainView()
        .environmentObject(ThemeManager())
}
