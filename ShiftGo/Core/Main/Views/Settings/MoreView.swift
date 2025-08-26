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
                    // 用戶角色信息
                    UserInfoSection()

                    // 根據角色顯示不同的功能分組
                    if userManager.currentRole == .boss {
                        BossSettingsSection()
                    } else {
                        EmployeeSettingsSection()
                    }

                    // Preferences 分組
                    PreferencesSection(themeManager: themeManager)

                    // Support 分組
                    SupportSection()

                    // 登出按鈕
                    LogoutSection()

                    Spacer()
                    VersionInfo()
                }
            }
        }
    }
}

struct UserInfoSection: View {
    @EnvironmentObject var userManager: UserManager

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: userManager.currentRole == .boss ? "person.badge.key.fill" : "person.fill")
                        .font(.title)
                        .foregroundColor(userManager.currentRole == .boss ? .purple : .blue)
                        .frame(width: 50)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Current Role")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(userManager.currentRole.displayName)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }

                    Spacer()

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
                .padding()
            }
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
}

// Boss 專用設定分組
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
            }
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
}

// Employee 專用設定分組
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

// 登出分組
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

                    Text("Logout")
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
        .alert("Logout", isPresented: $showingLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Logout", role: .destructive) {
                userManager.logout()
            }
        } message: {
            Text("Are you sure you want to logout?")
        }
    }
}

// Preferences 分組組件
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

// Support 分組組件
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

// Section 標題組件
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

// Dark Mode 專用行組件
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

// 設定分隔線組件
struct SettingDivider: View {
    var body: some View {
        Divider()
            .padding(.leading, 50)
    }
}

// 版本信息組件
struct VersionInfo: View {
    var body: some View {
        Text("Version 2025.22")
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.bottom, 20)
    }
}

#Preview {
    MoreView()
        .environmentObject(ThemeManager())
        .environmentObject(UserManager())
}
