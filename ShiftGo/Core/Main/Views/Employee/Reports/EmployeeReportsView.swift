//
//  EmployeeReportsView.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/8/25.
//

import SwiftUI

struct EmployeeReportsView: View {

    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            Text("Reports")
                .font(.largeTitle)
                .foregroundColor(AppColors.Text.header(colorScheme))

            Text("統計報表功能開發中...")
                .font(.body)
                .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.7))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmployeeReportsView()
        .environmentObject(ThemeManager())
}
