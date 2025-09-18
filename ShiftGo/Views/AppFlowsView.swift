//
//  AppFlowsView.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/9/18.
//

import SwiftUI

// MARK: - Main App View
struct MainAppView: View {
    @EnvironmentObject var userManager: UserManager

    var body: some View {
        Group {
            switch userManager.currentRole {
            case .employee:
                EmployeeAppView()
            case .boss:
                BossAppView()
            }
        }
    }
}

// MARK: - Employee App View
struct EmployeeAppView: View {
    @State private var selectedTab: EmployeeTab = .calendar

    var body: some View {
        VStack(spacing: 0) {
            EmployeeContentView(selectedTab: selectedTab)
            EmployeeTabBarView(selectedTab: $selectedTab)
        }
    }
}

// MARK: - Boss App View
struct BossAppView: View {
    @State private var selectedTab: BossTab = .dashboard

    var body: some View {
        VStack(spacing: 0) {
            BossContentView(selectedTab: selectedTab)
            BossTabBarView(selectedTab: $selectedTab)
        }
    }
}

// MARK: - Content Views
struct EmployeeContentView: View {
    let selectedTab: EmployeeTab

    var body: some View {
        Group {
            switch selectedTab {
            case .calendar:
                EmployeeMainView()
            case .reports:
                EmployeeReportsView()
            case .templates:
                TimeTrackerView()
            case .more:
                MoreView()
            }
        }
    }
}

struct BossContentView: View {
    let selectedTab: BossTab

    var body: some View {
        Group {
            switch selectedTab {
            case .dashboard:
                BossMainView()
            case .employees:
                BossMainView() // TODO: 將來替換為員工管理視圖
            case .schedules:
                BossMainView() // TODO: 將來替換為班表管理視圖
            case .analytics:
                BossMainView() // TODO: 將來替換為分析視圖
            case .more:
                MoreView()
            }
        }
    }
}
