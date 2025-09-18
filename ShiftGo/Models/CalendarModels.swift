//
//  CalendarModels.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/8/25.
//

import Foundation
import SwiftUI

// MARK: - Year Month
public struct YearMonth: Equatable, Hashable {
    public let year: Int
    public let month: Int

    public init(year: Int, month: Int) {
        self.year = year
        self.month = month
    }

    public static var current: YearMonth {
        let today = Date()
        return YearMonth(
            year: Calendar.current.component(.year, from: today),
            month: Calendar.current.component(.month, from: today)
        )
    }

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.year == rhs.year && lhs.month == rhs.month
    }

    public var monthShortString: String {
        var components = toDateComponents()
        components.day = 1
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: Calendar.current.date(from: components)!)
    }

    public var localizedMonthString: String {
        let monthNames = [
            1: "month_january".localized,
            2: "month_february".localized,
            3: "month_march".localized,
            4: "month_april".localized,
            5: "month_may".localized,
            6: "month_june".localized,
            7: "month_july".localized,
            8: "month_august".localized,
            9: "month_september".localized,
            10: "month_october".localized,
            11: "month_november".localized,
            12: "month_december".localized
        ]
        return monthNames[month] ?? "\(month)"
    }

    public func addMonth(value: Int) -> YearMonth {
        let gregorianCalendar = NSCalendar(calendarIdentifier: .gregorian)!
        let toDate = self.toDateComponents()
        var components = DateComponents()
        components.month = value
        let addedDate = Calendar.current.date(byAdding: components, to: gregorianCalendar.date(from: toDate)!)!
        return YearMonth(
            year: Calendar.current.component(.year, from: addedDate),
            month: Calendar.current.component(.month, from: addedDate)
        )
    }
    
    public func diffMonth(value: YearMonth) -> Int {
            var origin = self.toDateComponents()
            origin.day = 1
            origin.hour = 0
            origin.minute = 0
            origin.second = 0
            var new = value.toDateComponents()
            new.day = 1
            new.hour = 0
            new.minute = 0
            new.second = 0
            return Calendar.current.dateComponents([.month], from: Calendar.current.date(from: origin)!, to: Calendar.current.date(from: new)!).month!
        }

    public func toDateComponents() -> DateComponents {
        var components = DateComponents()
        components.year = self.year
        components.month = self.month
        return components
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.year)
        hasher.combine(self.month)
    }
}

// MARK: - Year Month Day
public struct YearMonthDay: Equatable, Hashable {
    public let year: Int
    public let month: Int
    public let day: Int
    public let isFocusYearMonth: Bool?

    public init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
        self.isFocusYearMonth = nil
    }

    public init(year: Int, month: Int, day: Int, isFocusYearMonth: Bool) {
        self.year = year
        self.month = month
        self.day = day
        self.isFocusYearMonth = isFocusYearMonth
    }

    public static var current: YearMonthDay {
        let today = Date()
        return YearMonthDay(
            year: Calendar.current.component(.year, from: today),
            month: Calendar.current.component(.month, from: today),
            day: Calendar.current.component(.day, from: today)
        )
    }

    public var isToday: Bool {
        let today = Date()
        let year = Calendar.current.component(.year, from: today)
        let month = Calendar.current.component(.month, from: today)
        let day = Calendar.current.component(.day, from: today)
        return self.year == year && self.month == month && self.day == day
    }

    public var dayOfWeek: Week {
        let weekday = Calendar.current.component(.weekday, from: self.date!)
        return Week.allCases[weekday - 1]
    }

    public var date: Date? {
        let gregorianCalendar = NSCalendar(calendarIdentifier: .gregorian)!
        return gregorianCalendar.date(from: self.toDateComponents())
    }

    public var formattedString: String {
        return String(format: "%04d-%02d-%02d", year, month, day)
    }

    public func toDateComponents() -> DateComponents {
        var components = DateComponents()
        components.year = self.year
        components.month = self.month
        components.day = self.day
        return components
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.year)
        hasher.combine(self.month)
        hasher.combine(self.day)
    }

    public var isWeekend: Bool { dayOfWeek.isWeekend }
    public var yearMonth: YearMonth { YearMonth(year: year, month: month) }
}

// MARK: - Calendar Constants
public struct CalendarConstants {
    public static let MAX_PAGE = 100
    public static let CENTER_PAGE = 50
    public static let COLUMN_COUNT = 7
    public static let ROW_COUNT = 6
    public static let MIN_TOUCH_TARGET = 44.0
    public static let CELL_SPACING = 2.0
    public static let ANIMATION_DURATION = 0.3
}
