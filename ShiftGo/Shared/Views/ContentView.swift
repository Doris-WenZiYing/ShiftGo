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

    // 🔥 新增：追蹤初始化狀態
    @State private var isInitializing = true
    @State private var initializationTimer: Timer?

    var body: some View {
        Group {
            if isInitializing {
                // 🔥 顯示 Onboarding 畫面
                OnboardingView()
            } else {
                // 原有的邏輯
                if userManager.isLoggedIn {
                    authenticatedView()
                        .environmentObject(themeManager)
                        .environmentObject(userManager)
                } else {
                    LoginView()
                        .environmentObject(userManager)
                }
            }
        }
        .preferredColorScheme(themeManager.preferredColorScheme)
        .onAppear {
            startInitializationProcess()
        }
    }

    // MARK: - 🔥 初始化流程
    private func startInitializationProcess() {
        print("🚀 開始初始化流程")

        // 設置最小顯示時間（避免閃爍）
        let minimumDisplayTime: TimeInterval = 1.5

        initializationTimer = Timer.scheduledTimer(withTimeInterval: minimumDisplayTime, repeats: false) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                isInitializing = false
            }
            print("✅ 初始化完成")
        }
    }

    // MARK: - 🔥 已認證用戶的視圖邏輯
    @ViewBuilder
    private func authenticatedView() -> some View {
        if userManager.isGuest {
            guestModeView()
        } else if userManager.currentCompany != nil {
            MainAppView()
        } else {
            CompanySetupView()
        }
    }

    // MARK: - 🔥 訪客模式視圖
    @ViewBuilder
    private func guestModeView() -> some View {
        VStack(spacing: 0) {
            guestModeHeader()
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
                try? userManager.signOut()
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
        .background(Color(.systemGray6))
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

// Employee 應用視圖
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

// Boss 應用視圖
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

// MARK: - 4. 更新後的 UserManager 改善
extension UserManager {
    /// 🔥 檢查初始化是否完成
    var isInitialized: Bool {
        // 如果是訪客模式，立即視為已初始化
        if isGuest { return true }

        // 如果已登入，檢查是否有完整的用戶和公司資料
        if isLoggedIn {
            return currentUser != nil
        }

        // 未登入狀態也視為已初始化
        return !isLoading
    }
}


#Preview {
    ContentView()
}
