//
//  ContentView.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/8/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var userManager = UserManager.shared

    var body: some View {
        Group {
            if userManager.isLoggedIn {
                authenticatedView()
                    .environmentObject(themeManager)
                    .environmentObject(userManager)
            } else {
                LoginView()  // 🔥 保持使用你現有的 LoginView，但會修改其功能
                    .environmentObject(userManager)
            }
        }
        .preferredColorScheme(themeManager.preferredColorScheme)
    }

    // MARK: - 🔥 新增：已認證用戶的視圖邏輯
    @ViewBuilder
    private func authenticatedView() -> some View {
        if userManager.isGuest {
            // 訪客模式：顯示員工界面 + 限制提示
            guestModeView()
        } else if userManager.currentCompany != nil {
            // 已加入組織：顯示主應用界面
            MainAppView()
        } else {
            // 已登入但未加入組織：顯示組織設置界面
            CompanySetupView()
        }
    }

    // MARK: - 🔥 訪客模式視圖
    @ViewBuilder
    private func guestModeView() -> some View {
        VStack(spacing: 0) {
            // 訪客模式提示條
            guestModeHeader()

            // 主應用界面（功能受限）
            MainAppView()
                .overlay(
                    guestLimitationsOverlay(),
                    alignment: .bottom
                )
        }
    }

    private func guestModeHeader() -> some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "person.crop.circle.dashed")
                    .font(.system(size: 14))
                    .foregroundColor(.orange)

                Text("訪客模式")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.orange)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(16)

            Spacer()

            Button("註冊解鎖") {
                try? userManager.signOut() // 退出訪客模式
            }
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.blue)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(16)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(AppColors.Background.secondary(.light))
    }

    private func guestLimitationsOverlay() -> some View {
        VStack {
            Spacer()

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("訪客模式限制")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.orange)

                    Text("無法儲存資料・功能受限")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.8))
                }

                Spacer()

                Button("立即註冊") {
                    try? userManager.signOut()
                }
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue)
                .cornerRadius(8)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
        }
    }
}

// MARK: - 🔥 新增：組織設置視圖


// MARK: - 主應用視圖 (保持現有結構)
struct MainAppView: View {
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        switch userManager.currentRole {
        case .employee:
            EmployeeAppView()
        case .boss:
            BossAppView()
        }
    }
}

// Employee 應用視圖 (保持現有)
struct EmployeeAppView: View {
    @State private var selectedTab: EmployeeTab = .calendar

    var body: some View {
        VStack(spacing: 0) {
            switch selectedTab {
            case .calendar:
                EmployeeMainView()
            case .reports:
                EmployeeReportsView()
            case .templates:
                EmployeeTemplateView()
            case .more:
                MoreView()
            }

            EmployeeTabBarView(selectedTab: $selectedTab)
        }
    }
}

// Boss 應用視圖 (保持現有)
struct BossAppView: View {
    @State private var selectedTab: BossTab = .dashboard

    var body: some View {
        VStack(spacing: 0) {
            switch selectedTab {
            case .dashboard:
                BossMainView()
            case .employees:
                BossMainView()
            case .schedules:
                BossMainView()
            case .analytics:
                BossMainView()
            case .more:
                MoreView()
            }

            BossTabBarView(selectedTab: $selectedTab)
        }
    }
}

#Preview {
    ContentView()
}
