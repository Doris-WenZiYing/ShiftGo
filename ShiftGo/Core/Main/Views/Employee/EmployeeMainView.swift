//
//  EmployeeMainView.swift
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
    @State private var isScheduleViewPresented = false

    var body: some View {
        GeometryReader { reader in
            ZStack {
                VStack(spacing: 0) {
                    headerSection()
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
            viewModel.loadData(for: controller.yearMonth.year, month: controller.yearMonth.month)
        }
        .onChange(of: controller.yearMonth) { _, newYearMonth in
            viewModel.loadData(for: newYearMonth.year, month: newYearMonth.month)
        }
        .refreshable {
            await viewModel.refreshData(for: controller.yearMonth.year, month: controller.yearMonth.month)
        }
    }

    // MARK: - Header Section
    private func headerSection() -> some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            HStack {
                Button(action: {
                    selectedMonth = controller.yearMonth.month
                    selectedYear = controller.yearMonth.year
                    isPickerPresented = true
                }) {
                    HStack(spacing: DesignTokens.Spacing.sm) {
                        Text("\(controller.yearMonth.monthString)")
                            .font(DesignTokens.Typography.title)
                            .foregroundColor(AppColors.Text.header(colorScheme))

                        Text("\(String(controller.yearMonth.year))")
                            .font(DesignTokens.Typography.body)
                            .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.8))

                        Image(systemName: "chevron.down")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppColors.Theme.primary)
                    }
                }
                .sheet(isPresented: $isPickerPresented) {
                    MonthPickerSheet(selectedYear: $selectedYear, selectedMonth: $selectedMonth, isPresented: $isPickerPresented, controller: controller)
                }

                Spacer()

                // Refresh button
                Button(action: {
                    viewModel.loadData(for: controller.yearMonth.year, month: controller.yearMonth.month)
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppColors.Theme.primary)
                        .opacity(viewModel.isLoading ? 0.5 : 1.0)
                }
                .disabled(viewModel.isLoading)

                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.Theme.primary))
                        .scaleEffect(0.8)
                        .padding(.leading, DesignTokens.Spacing.sm)
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)
        }
        .padding(.vertical, DesignTokens.Spacing.lg)
    }

    // MARK: - Calendar Section
    private func calendarSection() -> some View {
        VStack(spacing: 0) {
            CalendarView(controller, header: { week in
                GeometryReader { geometry in
                    Text(week.shortString)
                        .font(DesignTokens.Typography.captionMedium)
                        .foregroundColor(.secondary)
                        .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                }
            }, component: { date in
                GeometryReader { geometry in
                    VStack(spacing: DesignTokens.Spacing.xs) {
                        // Day number
                        Text("\(date.day)")
                            .font(.system(
                                size: 16,
                                weight: focusDate == date ? .bold : .medium,
                                design: .default
                            ))
                            .opacity(date.isFocusYearMonth == true ? 1 : 0.4)
                            .foregroundColor(getDateTextColor(date))
                            .frame(height: 22)

                        // My vacation indicator
                        if hasMyVacationOn(date) {
                            Circle()
                                .fill(getMyVacationColor(date))
                                .frame(width: 6, height: 6)
                        } else {
                            Spacer()
                                .frame(height: 6)
                        }

                        Spacer()
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                    .background(
                        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.sm)
                            .fill(focusDate == date ? AppColors.Theme.primary.opacity(0.1) : Color.clear)
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        focusDate = (date != focusDate ? date : nil)
                    }
                }
            })
        }
        .padding(.horizontal, DesignTokens.Spacing.lg)
    }

    // MARK: - Floating Button Section
    private func floatingButtonSection() -> some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    isScheduleViewPresented = true
                }) {
                    ZStack {
                        Circle()
                            .fill(viewModel.isVacationPublished ? AppColors.Theme.primary : AppColors.Theme.primary.opacity(0.6))
                            .frame(width: 56, height: 56)
                            .shadow(color: DesignTokens.Shadow.medium, radius: 8, x: 0, y: 4)

                        Image(systemName: viewModel.isVacationPublished ? "calendar.badge.plus" : "calendar.badge.exclamationmark")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
                .padding(.trailing, DesignTokens.Spacing.xl)
                .padding(.bottom, DesignTokens.Spacing.xxxl)
            }
        }
    }

    // MARK: - Toast Overlay
    private func toastOverlay() -> some View {
        VStack {
            Spacer()

            HStack(spacing: DesignTokens.Spacing.md) {
                Image(systemName: viewModel.toastType.icon)
                    .foregroundColor(AppColors.Theme.primary)

                Text(viewModel.toastMessage)
                    .font(DesignTokens.Typography.captionMedium)
                    .foregroundColor(AppColors.Text.header(colorScheme))

                Spacer()
            }
            .padding(.horizontal, DesignTokens.Spacing.xl)
            .padding(.vertical, DesignTokens.Spacing.lg)
            .background(.ultraThinMaterial)
            .cornerRadius(DesignTokens.CornerRadius.lg)
            .padding(.horizontal, DesignTokens.Spacing.xl)
            .padding(.bottom, 100)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: - Helper Methods
    private func getDateTextColor(_ date: YearMonthDay) -> Color {
        if hasMyVacationOn(date) {
            return getMyVacationColor(date)
        }

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
                return AppColors.Theme.primary
            case .rejected:
                return .red
            }
        }

        return AppColors.Theme.primary
    }
}

#Preview {
    EmployeeMainView()
        .environmentObject(ThemeManager())
}
