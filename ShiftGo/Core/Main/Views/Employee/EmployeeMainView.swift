//
//  EmployeeMainView.swift (Debug Version)
//  ShiftGo
//
//  Created by Doris Wen on 2025/8/25.
//

import SwiftUI

struct EmployeeMainView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var controller: CalendarController = CalendarController(orientation: .horizontal)
    @State var focusDate: YearMonthDay? = YearMonthDay.current

    @StateObject private var viewModel = EmployeeMainViewModel()

    @State private var isPickerPresented = false
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var selectedDate = Date()

    @State private var isScheduleViewPresented = false

    var body: some View {
        GeometryReader { reader in
            ZStack {
                VStack(alignment: .leading, spacing: 0) {
                    // Header with month selector and status
                    headerSection()

                    // Debug info section (可以之後移除)
                    debugInfoSection()

                    // Calendar view
                    calendarSection()
                }
                .background(AppColors.Background.primary(colorScheme))

                // Floating Button
                floatingButtonSection()

                // Toast overlay
                if viewModel.showingToast {
                    toastOverlay()
                }
            }
        }
        .sheet(isPresented: $isScheduleViewPresented) {
            EmployeeScheduleView(isPresented: $isScheduleViewPresented, controller: controller)
                .environmentObject(themeManager)
        }
        .onAppear {
            print("🔵 EmployeeMainView onAppear - Loading data for \(controller.yearMonth.year)/\(controller.yearMonth.month)")
            viewModel.loadData(for: controller.yearMonth.year, month: controller.yearMonth.month)
        }
        .onChange(of: controller.yearMonth) { _, newYearMonth in
            print("🔄 Month changed to \(newYearMonth.year)/\(newYearMonth.month)")
            viewModel.loadData(for: newYearMonth.year, month: newYearMonth.month)
        }
        .refreshable {
            // 下拉刷新功能
            print("🔄 Manual refresh triggered")
            await viewModel.refreshData(for: controller.yearMonth.year, month: controller.yearMonth.month)
        }
    }

    // MARK: - Debug Info Section (臨時用於除錯)
    private func debugInfoSection() -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("🐛 Debug Info")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.red)

            Text("當前月份: \(controller.yearMonth.year)/\(controller.yearMonth.month)")
                .font(.system(size: 9))
                .foregroundColor(.gray)

            Text("排休開放: \(viewModel.isVacationPublished ? "✅ 是" : "❌ 否")")
                .font(.system(size: 9))
                .foregroundColor(viewModel.isVacationPublished ? .green : .red)

            if let settings = viewModel.vacationSettings {
                Text("設定: \(settings.targetYear)/\(getMonthNumber(from: settings.targetMonth)) (發布:\(settings.isPublished ? "是" : "否"))")
                    .font(.system(size: 9))
                    .foregroundColor(.gray)
            } else {
                Text("設定: 無資料")
                    .font(.system(size: 9))
                    .foregroundColor(.red)
            }

            Text("我的申請: \(viewModel.myVacationRequests.count) 筆")
                .font(.system(size: 9))
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.yellow.opacity(0.1))
    }

    // MARK: - Header Section
    private func headerSection() -> some View {
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

                // Refresh button
                Button(action: {
                    print("🔄 Manual refresh button pressed")
                    viewModel.loadData(for: controller.yearMonth.year, month: controller.yearMonth.month)
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.Text.header(colorScheme))
                        .opacity(viewModel.isLoading ? 0.5 : 1.0)
                }
                .disabled(viewModel.isLoading)
                .padding(.trailing, 8)

                // Loading indicator
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.Calendar.saturday))
                        .scaleEffect(0.8)
                        .padding(.trailing, 16)
                }
            }

            // Status indicators
            statusIndicators()
                .padding(.horizontal, 16)
        }
        .padding(.vertical, 12)
    }

    private func statusIndicators() -> some View {
        let vacationStatus = viewModel.getVacationStatus(for: controller.yearMonth.year, month: controller.yearMonth.month)

        return HStack(spacing: 8) {
            // Vacation availability status
            HStack(spacing: 6) {
                Circle()
                    .fill(viewModel.isVacationPublished ? Color.green : Color.orange)
                    .frame(width: 8, height: 8)

                Text(viewModel.isVacationPublished ? "可申請" : "未開放")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(viewModel.isVacationPublished ? .green : .orange)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill((viewModel.isVacationPublished ? Color.green : Color.orange).opacity(0.1))
            )

            // My vacation status
            if viewModel.hasExistingRequest(for: controller.yearMonth.year, month: controller.yearMonth.month) {
                HStack(spacing: 6) {
                    Image(systemName: vacationStatus.icon)
                        .font(.system(size: 10))
                        .foregroundColor(vacationStatus.color)

                    Text(vacationStatus.displayText)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(vacationStatus.color)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(vacationStatus.color.opacity(0.1))
                )
            }

            Spacer()
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
                            .foregroundColor(getDateTextColor(date))
                            .frame(height: 20)
                            .padding(.top, 4)

                        // My vacation indicator
                        if hasMyVacationOn(date) {
                            Text("休")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background(getMyVacationColor(date))
                                .cornerRadius(2)
                        }

                        Spacer()
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                    .background(
                        focusDate == date ? Color.gray.opacity(0.15) : Color.clear
                    )
                    .cornerRadius(2)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        focusDate = (date != focusDate ? date : nil)
                    }
                }
            })
        }
    }

    // MARK: - Floating Button Section
    private func floatingButtonSection() -> some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    print("🎯 Floating button pressed - Vacation published: \(viewModel.isVacationPublished)")
                    isScheduleViewPresented = true
                }) {
                    ZStack {
                        Circle()
                            .fill(viewModel.isVacationPublished ? AppColors.Calendar.saturday : Color.gray)
                            .frame(width: 56, height: 56)
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)

                        Image(systemName: viewModel.isVacationPublished ? "calendar.badge.plus" : "calendar.badge.exclamationmark")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
                .padding(.trailing, 20)
                .padding(.bottom, 30)
            }
        }
    }

    // MARK: - Toast Overlay
    private func toastOverlay() -> some View {
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

    // MARK: - Helper Methods
    private func getDateTextColor(_ date: YearMonthDay) -> Color {
        // Check if I have vacation on this date
        if hasMyVacationOn(date) {
            return getMyVacationColor(date)
        }

        // Default color logic
        switch date.dayOfWeek {
        case .sun:
            return AppColors.Calendar.sunday
        case .sat:
            return AppColors.Calendar.saturday
        default:
            return AppColors.Calendar.dayText(colorScheme)
        }
    }

    private func hasMyVacationOn(_ date: YearMonthDay) -> Bool {
        let dateString = String(format: "%04d-%02d-%02d", date.year, date.month, date.day)

        return viewModel.myVacationRequests.contains { vacation in
            vacation.dates.contains(dateString)
        }
    }

    private func getMyVacationColor(_ date: YearMonthDay) -> Color {
        let dateString = String(format: "%04d-%02d-%02d", date.year, date.month, date.day)

        if let vacation = viewModel.myVacationRequests.first(where: { $0.dates.contains(dateString) }) {
            switch vacation.status {
            case .pending:
                return .orange
            case .approved:
                return .green
            case .rejected:
                return .red
            }
        }

        return .gray
    }

    private func getMonthNumber(from monthString: String) -> Int {
        let monthMap = [
            "1月": 1, "2月": 2, "3月": 3, "4月": 4,
            "5月": 5, "6月": 6, "7月": 7, "8月": 8,
            "9月": 9, "10月": 10, "11月": 11, "12月": 12
        ]
        return monthMap[monthString] ?? 1
    }
}

#Preview {
    EmployeeMainView()
        .environmentObject(ThemeManager())
}
