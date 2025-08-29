//
//  Color+YearMonthDay.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/8/27.
//

import SwiftUI

extension YearMonthDay {
    func dayColor(for colorScheme: ColorScheme) -> Color {
        switch self.dayOfWeek {
        case .sun:
            return AppColors.Calendar.sunday
        case .sat:
            return AppColors.Calendar.saturday
        default:
            return AppColors.Calendar.dayText(colorScheme)
        }
    }
}
