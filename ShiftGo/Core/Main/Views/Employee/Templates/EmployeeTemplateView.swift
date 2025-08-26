//
//  EmployeeTemplateView.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/8/26.
//

import SwiftUI

struct EmployeeTemplateView: View {

    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            Text("Templates")
                .font(.largeTitle)
                .foregroundColor(.white)

            Text("功能開發中...")
                .font(.body)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmployeeTemplateView()
        .environmentObject(ThemeManager())
}
