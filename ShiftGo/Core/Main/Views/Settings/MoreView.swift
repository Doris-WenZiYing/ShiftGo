//
//  MoreView.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/8/25.
//

import SwiftUI

struct MoreView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var userManager: UserManager
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 🔥 用戶資訊區域 (更新為使用真實用戶資料)
                    UserInfoSection()

                    // 🔥 根據角色和登入狀態顯示不同的功能分組
                    if userManager.isLoggedIn {
                        if userManager.currentRole == .boss {
                            BossSettingsSection()
                        } else {
                            EmployeeSettingsSection()
                        }
                    }

                    // Preferences 分組 (保持現有)
                    PreferencesSection(themeManager: themeManager)

                    // Support 分組 (保持現有)
                    SupportSection()

                    // 🔥 登出按鈕 (更新為使用新的 UserManager)
                    LogoutSection()

                    Spacer()
                    VersionInfo()
                }
            }
        }
    }
}

// MARK: - 🔥 更新的用戶資訊區域
struct UserInfoSection: View {
    @EnvironmentObject var userManager: UserManager

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(spacing: 0) {
                HStack {
                    // 🔥 根據用戶狀態顯示不同圖標
                    Image(systemName: getUserIcon())
                        .font(.title)
                        .foregroundColor(getUserIconColor())
                        .frame(width: 50)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(getUserStatusTitle())
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(getUserDisplayName())
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)

                        // 🔥 顯示公司資訊
                        if let company = userManager.currentCompany {
                            Text(company.name)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else if userManager.isGuest {
                            Text("訪客模式")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }

                    Spacer()

                    // 🔥 角色切換按鈕 (只在訪客模式顯示)
                    if userManager.isGuest {
                        Button(action: {
                            userManager.switchRole()
                        }) {
                            Text("Switch")
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }

    // MARK: - Helper Methods
    private func getUserIcon() -> String {
        if userManager.isGuest {
            return "person.crop.circle.dashed"
        } else {
            switch userManager.currentRole {
            case .boss:
                return "person.badge.key.fill"
            case .employee:
                return "person.fill"
            }
        }
    }

    private func getUserIconColor() -> Color {
        if userManager.isGuest {
            return .orange
        } else {
            switch userManager.currentRole {
            case .boss:
                return .purple
            case .employee:
                return .blue
            }
        }
    }

    private func getUserStatusTitle() -> String {
        if userManager.isGuest {
            return "訪客模式"
        } else {
            switch userManager.currentRole {
            case .boss:
                return "管理者"
            case .employee:
                return "員工"
            }
        }
    }

    private func getUserDisplayName() -> String {
        if let user = userManager.currentUser {
            return user.name
        } else {
            return "未登入"
        }
    }
}

// Boss 專用設定分組 (保持現有)
struct BossSettingsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: "Management")

            VStack(spacing: 0) {
                SettingRow(icon: "person.2.fill", title: "Employee Management", iconColor: .blue)
                SettingDivider()
                SettingRow(icon: "calendar.badge.clock", title: "Schedule Management", iconColor: .green)
                SettingDivider()
                SettingRow(icon: "chart.line.uptrend.xyaxis", title: "Analytics & Reports", iconColor: .purple)
                SettingDivider()
                SettingRow(icon: "bell.badge.fill", title: "Notifications", iconColor: .red)
                SettingDivider()
                SettingRow(icon: "building.2.fill", title: "Company Settings", iconColor: .orange)
            }
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
}

// Employee 專用設定分組 (保持現有)
struct EmployeeSettingsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: "My Settings")

            VStack(spacing: 0) {
                SettingRow(icon: "person.circle.fill", title: "Profile", iconColor: .blue)
                SettingDivider()
                SettingRow(icon: "calendar.badge.plus", title: "Shift Requests", iconColor: .green)
                SettingDivider()
                SettingRow(icon: "clock.badge.checkmark.fill", title: "Time Tracking", iconColor: .orange)
                SettingDivider()
                SettingRow(icon: "bell.fill", title: "Notifications", iconColor: .red)
            }
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
}

// 🔥 更新的登出分組
struct LogoutSection: View {
    @EnvironmentObject var userManager: UserManager
    @State private var showingLogoutAlert = false

    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                showingLogoutAlert = true
            }) {
                HStack {
                    Image(systemName: "power")
                        .font(.title3)
                        .foregroundColor(.red)
                        .frame(width: 30)

                    Text(getLogoutButtonText())
                        .font(.body)
                        .foregroundColor(.red)

                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
        .padding(.horizontal)
        .alert(getLogoutAlertTitle(), isPresented: $showingLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button(getLogoutConfirmText(), role: .destructive) {
                handleLogout()
            }
        } message: {
            Text(getLogoutAlertMessage())
        }
    }

    // MARK: - Helper Methods
    private func getLogoutButtonText() -> String {
        if userManager.isGuest {
            return "Exit Guest Mode"
        } else {
            return "Logout"
        }
    }

    private func getLogoutAlertTitle() -> String {
        if userManager.isGuest {
            return "Exit Guest Mode"
        } else {
            return "Logout"
        }
    }

    private func getLogoutConfirmText() -> String {
        if userManager.isGuest {
            return "Exit"
        } else {
            return "Logout"
        }
    }

    private func getLogoutAlertMessage() -> String {
        if userManager.isGuest {
            return "Are you sure you want to exit guest mode?"
        } else {
            return "Are you sure you want to logout?"
        }
    }

    private func handleLogout() {
        do {
            try userManager.signOut()  // 🔥 使用新的 signOut 方法
        } catch {
            print("Logout error: \(error)")
        }
    }
}

// Preferences 分組組件 (保持現有)
struct PreferencesSection: View {
    @ObservedObject var themeManager: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: "Preferences")

            VStack(spacing: 0) {
                SettingRow(icon: "display", title: "Display Options", iconColor: .blue)
                SettingDivider()
                DarkModeRow(themeManager: themeManager)
                SettingDivider()
                SettingRow(icon: "app.badge", title: "App Icon", iconColor: .orange)
                SettingDivider()
                SettingRow(icon: "widget.medium", title: "Widget", iconColor: .green)
                SettingDivider()
                SettingRow(icon: "globe", title: "Language", iconColor: .red)
            }
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
}

// Support 分組組件 (保持現有)
struct SupportSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: "Support")

            VStack(spacing: 0) {
                SettingRow(icon: "questionmark.circle.fill", title: "Help", iconColor: .blue)
                SettingDivider()
                SettingRow(icon: "arrow.triangle.2.circlepath", title: "Rotations", iconColor: .purple)
                SettingDivider()
                SettingRow(icon: "hand.raised.fill", title: "Privacy Policy", iconColor: .gray)
                SettingDivider()
                SettingRow(icon: "doc.text.fill", title: "EULA", iconColor: .teal)
            }
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
}

// Section 標題組件 (保持現有)
struct SectionHeader: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.bottom, 12)
    }
}

// Dark Mode 專用行組件 (保持現有)
struct DarkModeRow: View {
    @ObservedObject var themeManager: ThemeManager

    var body: some View {
        NavigationLink(destination: ThemeSelectionView(themeManager: themeManager)) {
            HStack {
                Image(systemName: "moon.fill")
                    .font(.title3)
                    .foregroundColor(.indigo)
                    .frame(width: 30)

                Text("Dark Mode")
                    .font(.body)
                    .foregroundColor(.primary)

                Spacer()

                Text(themeManager.currentTheme.displayName)
                    .font(.body)
                    .foregroundColor(.secondary)

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
    }
}

// 設定分隔線組件 (保持現有)
struct SettingDivider: View {
    var body: some View {
        Divider()
            .padding(.leading, 50)
    }
}

// 版本信息組件 (保持現有)
struct VersionInfo: View {
    var body: some View {
        VStack(spacing: 4) {
            Text("ShiftGo")
                .font(.caption)
                .foregroundColor(.secondary)

            Text("Version 1.0.0")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.bottom, 20)
    }
}

#Preview {
    MoreView()
        .environmentObject(ThemeManager())
        .environmentObject(UserManager.shared)
}
