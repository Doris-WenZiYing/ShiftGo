//
//  ContentView.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/8/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var userManager = UserManager()

    var body: some View {
        Group {
            if userManager.isLoggedIn {
                MainAppView()
                    .environmentObject(themeManager)
                    .environmentObject(userManager)
            } else {
                LoginView()
                    .environmentObject(userManager)
            }
        }
        .preferredColorScheme(themeManager.preferredColorScheme)
    }
}

// 主應用視圖 - 根據角色顯示不同界面
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
            // Employee 主內容區域
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

            // Employee Tab Bar
            EmployeeTabBarView(selectedTab: $selectedTab)
        }
    }
}

// Boss 應用視圖
struct BossAppView: View {
    @State private var selectedTab: BossTab = .dashboard

    var body: some View {
        VStack(spacing: 0) {
            // Boss 主內容區域
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

            // Boss Tab Bar
            BossTabBarView(selectedTab: $selectedTab)
        }
    }
}

#Preview {
    ContentView()
}
