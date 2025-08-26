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

    @State private var isPickerPresented = false
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var selectedDate = Date()

    var body: some View {
        GeometryReader { reader in
            VStack(alignment: .leading) {
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

                VStack(alignment: .leading, spacing: 0) {
                    CalendarView(controller, header: { week in
                        GeometryReader { geometry in
                            Text(week.shortString)
                                .font(.subheadline)
                                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                        }
                    }, component: { date in
                        GeometryReader { geometry in
                            Text("\(date.day)")
                                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
                                .padding(.top, 4)
                                .padding(.bottom, -4)
                                .font(.system(
                                    size: 14,
                                    weight: focusDate == date ? .bold : .light,
                                    design: .default
                                ))
                                .opacity(date.isFocusYearMonth == true ? 1 : 0.4)
                                .foregroundColor(getColor(date))
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
                    .sheet(isPresented: $isPickerPresented) {
                        MonthPickerSheet(selectedYear: $selectedYear, selectedMonth: $selectedMonth, isPresented: $isPickerPresented, controller: controller)
                    }
                }
            }
            .background(AppColors.Background.primary(colorScheme))
        }
    }
    private func getColor(_ date: YearMonthDay) -> Color {
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

#Preview {
    EmployeeMainView()
        .environmentObject(ThemeManager())
}
