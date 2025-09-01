//
//  EmployeeTemplateView.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/8/26.
//

import SwiftUI

struct EmployeeTemplateView: View {

    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            Text("Templates")
                .font(.largeTitle)
                .foregroundColor(AppColors.Text.header(colorScheme))

            Text("功能開發中...")
                .font(.body)
                .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.7))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmployeeTemplateView()
        .environmentObject(ThemeManager())
}
