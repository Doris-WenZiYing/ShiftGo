//
//  ThemeSelectionView.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/8/26.
//

import SwiftUI

struct ThemeSelectionView: View {
    @ObservedObject var themeManager: ThemeManager
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                ForEach(ThemeOption.allCases, id: \.self) { theme in
                    ThemeOptionRow(theme: theme, themeManager: themeManager)

                    if theme != ThemeOption.allCases.last {
                        Divider()
                            .padding(.leading, 16)
                    }
                }
            }
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.top, 20)

            Spacer()
        }
        .navigationTitle("Dark Mode")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ThemeOptionRow: View {
    let theme: ThemeOption
    @ObservedObject var themeManager: ThemeManager

    var body: some View {
        Button(action: {
            themeManager.selectedTheme = theme.rawValue
        }) {
            HStack {
                Text(theme.rawValue)
                    .font(.body)
                    .foregroundColor(.primary)

                Spacer()

                if themeManager.selectedTheme == theme.rawValue {
                    Image(systemName: "largecircle.fill.circle")
                        .foregroundColor(.blue)
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 16)
        }
    }
}

#Preview {
    ThemeSelectionView(themeManager: ThemeManager())
        .environmentObject(ThemeManager())
}
