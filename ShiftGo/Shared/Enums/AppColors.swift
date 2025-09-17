//
//  AppColors.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/8/26.
//

import SwiftUI

// MARK: - 顏色管理系統
struct AppColors {

    // MARK: - 主題顏色（新增）
    struct Theme {
        static let primary = Color(hex: "ff6b3d")  // 你指定的主題色
        static let secondary = Color(hex: "007a91")  // 稍深一點的變化色
        static let light = Color(hex: "33aac4")  // 稍淺一點的變化色
    }

    // MARK: - 背景顏色
    struct Background {
        static func primary(_ colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? .black.opacity(0.8) : .white
        }

        static func secondary(_ colorScheme: ColorScheme) -> Color {
            Color(.systemGray6)
        }

        static func tabBar(_ colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? .black : .white
        }

        static func blackBg(_ colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? .black : .white
        }
    }

    // MARK: - 文字顏色
    struct Text {
        static func primary(_ colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? .white : .black
        }

        static func secondary(_ colorScheme: ColorScheme) -> Color {
            .secondary
        }

        static func header(_ colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? .white : .black
        }

        static func calendar(_ colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? .white : .black
        }
    }

    // MARK: - Tab Bar 顏色
    struct TabBar {
        static func selected(_ colorScheme: ColorScheme) -> Color {
            Theme.primary  // 使用主題色作為選中狀態
        }

        static func unselected(_ colorScheme: ColorScheme) -> Color {
            .gray
        }

        static func background(_ colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? .black : .white
        }
    }

    // MARK: - 強調色彩（固定不變的顏色）
    struct Accent {
        static let primary = Theme.primary  // 新增：主要強調色使用主題色
        static let orange = Color.orange
        static let blue = Color.blue
        static let red = Color.red
        static let green = Color.green
        static let purple = Color.purple
        static let indigo = Color.indigo
        static let teal = Color.teal
        static let yellow = Color.yellow
    }

    // MARK: - 日曆特殊顏色
    struct Calendar {
        static let sunday = Color.red
        static let saturday = Color.blue
        static let selected = Theme.primary  // 使用主題色
        static let selectedBorder = Theme.primary  // 使用主題色

        static func dayText(_ colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? .white : .black
        }
    }

    // MARK: - 設定頁面顏色
    struct Settings {
        static let displayIcon = Theme.primary  // 使用主題色
        static let darkModeIcon = Color.indigo
        static let appIcon = Theme.primary  // 使用主題色
        static let widgetIcon = Color.green
        static let languageIcon = Color.red
        static let helpIcon = Theme.primary  // 使用主題色
        static let rotationIcon = Color.purple
        static let privacyIcon = Color.gray
        static let eulaIcon = Color.teal
        static let logoutIcon = Color.red
    }

    // MARK: - 角色相關顏色
    struct Role {
        static let employee = Theme.primary  // 使用主題色
        static let boss = Color.purple
    }

    // MARK: - 狀態顏色
    struct Status {
        static let success = Color.green
        static let warning = Color.orange
        static let error = Color.red
        static let info = Theme.primary  // 使用主題色
    }
}

// MARK: - Color 擴展，支持十六進制顏色
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Color 擴展，提供便利方法
extension Color {

    // 主題顏色（新增）
    static var appTheme: Color {
        AppColors.Theme.primary
    }

    static var appThemeSecondary: Color {
        AppColors.Theme.secondary
    }

    static var appThemeLight: Color {
        AppColors.Theme.light
    }

    // 背景顏色
    static func appBackground(_ colorScheme: ColorScheme) -> Color {
        AppColors.Background.primary(colorScheme)
    }

    static func appSecondaryBackground(_ colorScheme: ColorScheme) -> Color {
        AppColors.Background.secondary(colorScheme)
    }

    // 文字顏色
    static func appPrimaryText(_ colorScheme: ColorScheme) -> Color {
        AppColors.Text.primary(colorScheme)
    }

    static func appSecondaryText(_ colorScheme: ColorScheme) -> Color {
        AppColors.Text.secondary(colorScheme)
    }

    // Tab Bar 顏色
    static func tabSelected(_ colorScheme: ColorScheme) -> Color {
        AppColors.TabBar.selected(colorScheme)
    }

    static func tabUnselected(_ colorScheme: ColorScheme) -> Color {
        AppColors.TabBar.unselected(colorScheme)
    }

    static func tabBackground(_ colorScheme: ColorScheme) -> Color {
        AppColors.TabBar.background(colorScheme)
    }
}

// MARK: - View 擴展，提供環境感知的顏色
extension View {

    @ViewBuilder
    func appBackgroundColor() -> some View {
        self.modifier(AppBackgroundModifier())
    }

    @ViewBuilder
    func tabBarColors() -> some View {
        self.modifier(TabBarColorsModifier())
    }

    @ViewBuilder
    func themeAccent() -> some View {
        self.accentColor(AppColors.Theme.primary)
    }
}

// MARK: - ViewModifier for consistent styling
struct AppBackgroundModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .background(AppColors.Background.primary(colorScheme))
    }
}

struct TabBarColorsModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .background(AppColors.TabBar.background(colorScheme))
    }
}

struct ColorSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)

            content
        }
    }
}

struct ColorItem: View {
    let name: String
    let lightColor: Color?
    let darkColor: Color?
    let color: Color?

    init(name: String, lightColor: Color, darkColor: Color) {
        self.name = name
        self.lightColor = lightColor
        self.darkColor = darkColor
        self.color = nil
    }

    init(name: String, color: Color) {
        self.name = name
        self.lightColor = nil
        self.darkColor = nil
        self.color = color
    }

    var body: some View {
        HStack {
            Text(name)
                .font(.body)
                .foregroundColor(.primary)

            Spacer()

            if let color = color {
                Circle()
                    .fill(color)
                    .frame(width: 30, height: 30)
            } else {
                HStack(spacing: 8) {
                    if let lightColor = lightColor {
                        Circle()
                            .fill(lightColor)
                            .stroke(Color.gray, lineWidth: 1)
                            .frame(width: 30, height: 30)
                    }

                    if let darkColor = darkColor {
                        Circle()
                            .fill(darkColor)
                            .frame(width: 30, height: 30)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}
