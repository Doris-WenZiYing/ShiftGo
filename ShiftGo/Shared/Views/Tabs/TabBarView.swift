//
//  TabBarView.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/8/25.
//

import SwiftUI

// Employee Tab Bar
struct EmployeeTabBarView: View {
    @Binding var selectedTab: EmployeeTab
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack {
            ForEach(EmployeeTab.allCases, id: \.self) { tab in
                employeeTabItem(tab)
            }
        }
        .padding(.top, 5)
        .padding(.bottom, hasHomeIndicator() ? 8 : 12)
        .background(AppColors.TabBar.background(colorScheme))
    }

    func employeeTabItem(_ tab: EmployeeTab) -> some View {
        VStack(spacing: 2) {
            Image(systemName: tab.icon)
                .font(.system(size: 16))
                .foregroundColor(selectedTab == tab ? AppColors.TabBar.selected(colorScheme) : AppColors.TabBar.unselected(colorScheme))
            Text(tab.label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(selectedTab == tab ? AppColors.TabBar.selected(colorScheme) : AppColors.TabBar.unselected(colorScheme))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 44)
        .onTapGesture {
            selectedTab = tab
        }
    }

    private func hasHomeIndicator() -> Bool {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return false
        }
        return window.safeAreaInsets.bottom > 0
    }
}

// Boss Tab Bar
struct BossTabBarView: View {
    @Binding var selectedTab: BossTab
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack {
            ForEach(BossTab.allCases, id: \.self) { tab in
                bossTabItem(tab)
            }
        }
        .padding(.top, 5)
        .padding(.bottom, hasHomeIndicator() ? 8 : 12)
        .background(AppColors.TabBar.background(colorScheme))
    }

    func bossTabItem(_ tab: BossTab) -> some View {
        VStack(spacing: 2) {
            Image(systemName: tab.icon)
                .font(.system(size: 16))
                .foregroundColor(selectedTab == tab ? AppColors.TabBar.selected(colorScheme) : AppColors.TabBar.unselected(colorScheme))
            Text(tab.label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(selectedTab == tab ? AppColors.TabBar.selected(colorScheme) : AppColors.TabBar.unselected(colorScheme))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 44)
        .onTapGesture {
            selectedTab = tab
        }
    }

    private func hasHomeIndicator() -> Bool {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return false
        }
        return window.safeAreaInsets.bottom > 0
    }
}

struct GenericTabBarView<TabType: CaseIterable & Hashable>: View where TabType: RawRepresentable, TabType.RawValue == String {
    @Binding var selectedTab: TabType
    @Environment(\.colorScheme) var colorScheme
    let tabs: [TabType]
    let iconProvider: (TabType) -> String
    let labelProvider: (TabType) -> String

    var body: some View {
        HStack {
            ForEach(Array(tabs), id: \.self) { tab in
                tabItem(tab)
            }
        }
        .padding(.top, 5)
        .padding(.bottom, hasHomeIndicator() ? 8 : 12)
        .background(AppColors.TabBar.background(colorScheme))
    }

    func tabItem(_ tab: TabType) -> some View {
        VStack(spacing: 2) {
            Image(systemName: iconProvider(tab))
                .font(.system(size: 16))
                .foregroundColor(selectedTab == tab ? AppColors.TabBar.selected(colorScheme) : AppColors.TabBar.unselected(colorScheme))
            Text(labelProvider(tab))
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(selectedTab == tab ? AppColors.TabBar.selected(colorScheme) : AppColors.TabBar.unselected(colorScheme))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 44)
        .onTapGesture {
            selectedTab = tab
        }
    }

    private func hasHomeIndicator() -> Bool {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return false
        }
        return window.safeAreaInsets.bottom > 0
    }
}


#Preview("Employee Tab Bar") {
    EmployeeTabBarView(selectedTab: .constant(.calendar))
}

#Preview("Boss Tab Bar") {
    BossTabBarView(selectedTab: .constant(.dashboard))
}
