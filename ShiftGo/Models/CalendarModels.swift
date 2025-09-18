//
//  CalendarModels.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/8/25.
//

import Foundation
import SwiftUI

// MARK: - Week Enumeration
public enum Week: Int, CaseIterable {
    case sun = 0, mon = 1, tue = 2, wed = 3, thu = 4, fri = 5, sat = 6

    public var shortString: String {
        DateFormatter().shortWeekdaySymbols[self.rawValue]
    }

    public func shortString(locale: Locale) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        return formatter.shortWeekdaySymbols[self.rawValue]
    }

    public var localizedShortName: String {
        switch self {
        case .sun: return "calendar_sunday".localized
        case .mon: return "calendar_monday".localized
        case .tue: return "calendar_tuesday".localized
        case .wed: return "calendar_wednesday".localized
        case .thu: return "calendar_thursday".localized
        case .fri: return "calendar_friday".localized
        case .sat: return "calendar_saturday".localized
        }
    }

    public var isWeekend: Bool {
        return self == .sun || self == .sat
    }
}

// MARK: - Orientation
public enum Orientation {
    case horizontal
    case vertical
}

// MARK: - Header Size
public enum HeaderSize {
    case zero
    case ratio
    case fixHeight(CGFloat)
}

// MARK: - Year Month Structure
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
        components.hour = 0
        components.minute = 0
        components.second = 0
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: Calendar.current.date(from: components)!)
    }

    public var monthString: String {
        var components = toDateComponents()
        components.day = 1
        components.hour = 0
        components.minute = 0
        components.second = 0
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: Calendar.current.date(from: components)!)
    }

    public var localizedMonthString: String {
        switch month {
        case 1: return "month_january".localized
        case 2: return "month_february".localized
        case 3: return "month_march".localized
        case 4: return "month_april".localized
        case 5: return "month_may".localized
        case 6: return "month_june".localized
        case 7: return "month_july".localized
        case 8: return "month_august".localized
        case 9: return "month_september".localized
        case 10: return "month_october".localized
        case 11: return "month_november".localized
        case 12: return "month_december".localized
        default: return "\(month)"
        }
    }

    // ... (rest of the YearMonth implementation remains the same)

    public func addMonth(value: Int) -> YearMonth {
        let gregorianCalendar = NSCalendar(calendarIdentifier: .gregorian)!
        let toDate = self.toDateComponents()

        var components = DateComponents()
        components.month = value

        let addedDate = Calendar.current.date(byAdding: components, to: gregorianCalendar.date(from: toDate)!)!
        let ret = YearMonth(
            year: Calendar.current.component(.year, from: addedDate),
            month: Calendar.current.component(.month, from: addedDate)
        )
        return ret
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

    internal func cellToDate(_ cellIndex: Int, startWithMonday: Bool) -> YearMonthDay {
        let gregorianCalendar = NSCalendar(calendarIdentifier: .gregorian)!
        var toDateComponent = DateComponents()
        toDateComponent.year = self.year
        toDateComponent.month = self.month
        toDateComponent.day = 1
        let toDate = gregorianCalendar.date(from: toDateComponent)!
        let weekday = Calendar.current.component(.weekday, from: toDate)
        var components = DateComponents()
        components.day = cellIndex - weekday + (!startWithMonday ? 1 : weekday == 1 ? (-5) : 2)
        let addedDate = Calendar.current.date(byAdding: components, to: toDate)!
        let year = Calendar.current.component(.year, from: addedDate)
        let month = Calendar.current.component(.month, from: addedDate)
        let day = Calendar.current.component(.day, from: addedDate)
        let isFocusYaerMonth = year == self.year && month == self.month
        let ret = YearMonthDay(year: year, month: month, day: day, isFocusYearMonth: isFocusYaerMonth)
        return ret
    }
}

// MARK: - Year Month Day Structure
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

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.year == rhs.year && lhs.month == rhs.month && lhs.day == rhs.day
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

    public func addDay(value: Int) -> YearMonthDay {
        let gregorianCalendar = NSCalendar(calendarIdentifier: .gregorian)!
        let toDate = self.toDateComponents()

        var components = DateComponents()
        components.day = value

        let addedDate = Calendar.current.date(byAdding: components, to: gregorianCalendar.date(from: toDate)!)!
        let ret = YearMonthDay(
            year: Calendar.current.component(.year, from: addedDate),
            month: Calendar.current.component(.month, from: addedDate),
            day: Calendar.current.component(.day, from: addedDate)
        )
        return ret
    }

    public func diffDay(value: YearMonthDay) -> Int {
        var origin = self.toDateComponents()
        origin.hour = 0
        origin.minute = 0
        origin.second = 0
        var new = value.toDateComponents()
        new.hour = 0
        new.minute = 0
        new.second = 0
        return Calendar.current.dateComponents([.day], from: Calendar.current.date(from: origin)!, to: Calendar.current.date(from: new)!).day!
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.year)
        hasher.combine(self.month)
        hasher.combine(self.day)
    }
}

// MARK: - Calendar Constants
public struct CalendarConstants {
    public static let MAX_PAGE = 100
    public static let CENTER_PAGE = 50
    public static let COLUMN_COUNT = 7
    public static let ROW_COUNT = 6
}
