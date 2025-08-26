//
//  SettingRow.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/8/26.
//

import SwiftUI

struct SettingRow: View {
    let icon: String
    let title: String
    let iconColor: Color

    var body: some View {
        NavigationLink(destination: Text("功能開發中...")) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(iconColor)
                    .frame(width: 30)

                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
    }
}

#Preview {
    SettingRow(icon: "star", title: "title", iconColor: .red)
}
