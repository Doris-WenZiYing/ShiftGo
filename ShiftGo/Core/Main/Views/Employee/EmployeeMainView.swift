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

    @State private var isPickerPresented = false
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var selectedDate = Date()

    var body: some View {
        GeometryReader { reader in
            VStack(alignment: .leading) {
                // 月份年份按鈕
                Button(action: {
                    selectedMonth = controller.yearMonth.month
                    selectedYear = controller.yearMonth.year
                    isPickerPresented = true
                }) {
                    HStack(spacing: 8) {
                        Text("\(controller.yearMonth.monthString)")
                            .font(.system(size: 28, weight: .bold))
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
                    // 星期標題
                    HStack(alignment: .center, spacing: 0) {
                        ForEach(0..<7, id: \.self) { i in
                            Text(DateFormatter().shortWeekdaySymbols[i])
                                .font(.headline)
                                .foregroundColor(AppColors.Text.primary(colorScheme))
                                .frame(width: reader.size.width / 7)
                        }
                    }
                    .padding(.top, 10)

                    // 日曆視圖 - 保持垂直分頁模式，但修正觸摸問題
                    CalendarView(controller) { date in
                        CalendarDayView(
                            date: date,
                            selectedDate: selectedDate,
                            colorScheme: colorScheme,
                            onTap: { tappedDate in
                                print("點擊日期: \(tappedDate.day), isFocusYearMonth: \(tappedDate.isFocusYearMonth ?? false)")
                                if let actualDate = tappedDate.date {
                                    selectedDate = actualDate
                                    controller.selectDate(tappedDate)
                                }
                            }
                        )
                    }
                    .sheet(isPresented: $isPickerPresented) {
                        MonthPickerSheet(selectedYear: $selectedYear, selectedMonth: $selectedMonth, isPresented: $isPickerPresented, controller: controller)
                    }
                }
            }
            .background(AppColors.Background.primary(colorScheme))
        }
    }

    private func isSameDay(date: Date, selectedDate: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(date, inSameDayAs: selectedDate)
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

struct CalendarDayView: View {
    let date: YearMonthDay
    let selectedDate: Date
    let colorScheme: ColorScheme
    let onTap: (YearMonthDay) -> Void

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 選中狀態的方形邊框
                if isSameDay(date: date.date ?? Date(), selectedDate: selectedDate) {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(AppColors.Calendar.selectedBorder, lineWidth: 2)
                        .frame(width: geometry.size.width - 4, height: geometry.size.height - 4)
                }

                // 日期文字
                Text("\(date.day)")
                    .font(.system(size: 16, weight: isSameDay(date: date.date ?? Date(), selectedDate: selectedDate) ? .bold : .light))
                    .foregroundColor(isSameDay(date: date.date ?? Date(), selectedDate: selectedDate) ? AppColors.Calendar.selected : getColor(date))
                    .opacity(date.isFocusYearMonth == true ? 1 : 0.4)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.top, 4)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .contentShape(Rectangle()) // 確保整個區域可點擊
            .background(Color.clear) // 透明背景確保觸摸區域
            // 使用 highPriorityGesture 確保點擊優先於滑動
            .highPriorityGesture(
                TapGesture()
                    .onEnded { _ in

                        onTap(date)
                    }
            )
            // 同時允許長按（未來可擴展功能）
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.5)
                    .onEnded { _ in
                        // 長按事件（目前暫時不處理）
                        print("長按日期: \(date.day)")
                    }
            )
        }
    }

    private func isSameDay(date: Date, selectedDate: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(date, inSameDayAs: selectedDate)
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
