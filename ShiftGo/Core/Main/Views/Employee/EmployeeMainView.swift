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

    @State private var isScheduleViewPresented = false

    var body: some View {
        GeometryReader { reader in
            ZStack {
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
                                    .foregroundColor(date.dayColor(for: colorScheme))
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

                // Floating Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            isScheduleViewPresented = true
                        }) {
                            ZStack {
                                Circle()
                                    .fill(AppColors.Calendar.saturday)
                                    .frame(width: 56, height: 56)
                                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)

                                Image(systemName: "calendar.badge.plus")
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .sheet(isPresented: $isScheduleViewPresented) {
            EmployeeScheduleView(isPresented: $isScheduleViewPresented, controller: controller)
                .environmentObject(themeManager)
        }
    }
}

#Preview {
    EmployeeMainView()
        .environmentObject(ThemeManager())
}
