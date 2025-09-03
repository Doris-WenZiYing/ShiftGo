//
//  MoreView.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/8/25.
//

import SwiftUI
import Combine

struct MoreView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var userManager: UserManager
    @Environment(\.colorScheme) var colorScheme

    // 邀請碼相關狀態
    @State private var organizationInviteCode = ""
    @State private var isLoadingInviteCode = false
    @State private var showingInviteCodeSheet = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    UserInfoSection()

                    if userManager.isLoggedIn {
                        if userManager.currentRole == .boss {
                            // 整合邀請碼的老闆設定區塊
                            BossSettingsSection(
                                inviteCode: $organizationInviteCode,
                                isLoading: $isLoadingInviteCode,
                                showingSheet: $showingInviteCodeSheet,
                                loadInviteCode: loadInviteCode
                            )
                        } else {
                            EmployeeSettingsSection()
                        }
                    }

                    PreferencesSection(themeManager: themeManager)
                    SupportSection()
                    LogoutSection()

                    Spacer()
                    VersionInfo()
                }
            }
        }
        .sheet(isPresented: $showingInviteCodeSheet) {
            InviteCodeSheet(inviteCode: $organizationInviteCode)
                .presentationDetents([.medium])
        }
        .alert("錯誤", isPresented: $showingErrorAlert) {
            Button("確定") { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            if userManager.isLoggedIn && userManager.currentRole == .boss {
                preloadInviteCode()
            }
        }
    }

    // MARK: - 邀請碼方法
    private func preloadInviteCode() {
        guard let currentCompany = userManager.currentCompany else { return }
        organizationInviteCode = currentCompany.inviteCode
    }

    private func loadInviteCode() {
        guard userManager.isLoggedIn else {
            showError("請先登入後再試")
            return
        }

        guard userManager.currentRole == .boss else {
            showError("只有管理者可以查看邀請碼")
            return
        }

        guard let currentCompany = userManager.currentCompany else {
            showError("找不到組織資訊")
            return
        }

        organizationInviteCode = currentCompany.inviteCode

        if !organizationInviteCode.isEmpty {
            showingInviteCodeSheet = true
        } else {
            showError("邀請碼載入失敗")
        }
    }

    private func showError(_ message: String) {
        errorMessage = message
        showingErrorAlert = true
    }
}

// MARK: - 用戶資訊區域
struct UserInfoSection: View {
    @EnvironmentObject var userManager: UserManager

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(spacing: 0) {
                HStack {
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

                        if let company = userManager.currentCompany {
                            Text(company.name)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else if userManager.isGuest {
                            Text("訣客模式")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }

                    Spacer()

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

// MARK: - 整合邀請碼的 Boss 設定分組
struct BossSettingsSection: View {
    @Binding var inviteCode: String
    @Binding var isLoading: Bool
    @Binding var showingSheet: Bool
    let loadInviteCode: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: "Management")

            VStack(spacing: 0) {
                // 邀請碼行
                Button(action: loadInviteCode) {
                    HStack {
                        Image(systemName: "key.fill")
                            .font(.title3)
                            .foregroundColor(.green)
                            .frame(width: 30)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("組織邀請碼")
                                .font(.body)
                                .foregroundColor(.primary)
                        }

                        Spacer()

                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(isLoading)

                SettingDivider()

                // 其他管理功能
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

// MARK: - Employee 專用設定分組
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

// MARK: - 登出分組
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

                    Text(userManager.isGuest ? "Exit Guest Mode" : "Logout")
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
        .alert(userManager.isGuest ? "Exit Guest Mode" : "Logout", isPresented: $showingLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button(userManager.isGuest ? "Exit" : "Logout", role: .destructive) {
                do {
                    try userManager.signOut()
                } catch {
                    print("Logout error: \(error)")
                }
            }
        } message: {
            Text(userManager.isGuest ? "Are you sure you want to exit guest mode?" : "Are you sure you want to logout?")
        }
    }
}

// MARK: - Preferences 分組組件
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

// MARK: - Support 分組組件
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

// MARK: - Section 標題組件
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

// MARK: - Dark Mode 專用行組件
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

// MARK: - 設定分隔線組件
struct SettingDivider: View {
    var body: some View {
        Divider()
            .padding(.leading, 50)
    }
}

// MARK: - 版本信息組件
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

// MARK: - 邀請碼 Sheet
struct InviteCodeSheet: View {
    @Binding var inviteCode: String
    @Environment(\.dismiss) private var dismiss
    @State private var showingCopiedAlert = false

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "key.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)

                VStack(spacing: 12) {
                    Text("組織邀請碼")
                        .font(.system(size: 24, weight: .bold))

                    Text("分享此邀請碼給員工，讓他們加入您的組織")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: 16) {
                    Text(inviteCode.isEmpty ? "載入中..." : inviteCode)
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .foregroundColor(inviteCode.isEmpty ? .gray : .green)
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(12)
                        .onTapGesture {
                            copyInviteCode()
                        }
                }

                Button("複製邀請碼") {
                    copyInviteCode()
                }
                .buttonStyle(.borderedProminent)
                .disabled(inviteCode.isEmpty)

                Spacer()
            }
            .padding()
            .navigationTitle("邀請碼")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
        .alert("已複製", isPresented: $showingCopiedAlert) {
            Button("確定") { }
        } message: {
            Text("邀請碼已複製到剪貼板")
        }
    }

    private func copyInviteCode() {
        guard !inviteCode.isEmpty else { return }

        UIPasteboard.general.string = inviteCode
        showingCopiedAlert = true

        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
}

#Preview {
    MoreView()
        .environmentObject(ThemeManager())
        .environmentObject(UserManager.shared)
}
