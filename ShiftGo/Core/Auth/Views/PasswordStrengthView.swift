//
//  PasswordStrengthView.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/9/3.
//

import SwiftUI

struct PasswordStrengthView: View {
    let password: String
    @Environment(\.colorScheme) var colorScheme
    private var strength: PasswordValidator.PasswordStrength {
        PasswordValidator.getPasswordStrength(password)
    }

    private var requirements: [PasswordValidator.PasswordRequirement] {
        PasswordValidator.getPasswordRequirements(password)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 強度指示器
            if !password.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("密碼強度：")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppColors.Text.header(colorScheme))

                        Text(strength.text)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(strength.color)

                        Spacer()
                    }

                    // 進度條
                    ProgressView(value: strength.progress)
                        .progressViewStyle(LinearProgressViewStyle())
                        .accentColor(strength.color)
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                }

                // 要求列表
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(Array(requirements.enumerated()), id: \.offset) { index, requirement in
                        HStack(spacing: 8) {
                            Image(systemName: requirement.icon)
                                .font(.system(size: 12))
                                .foregroundColor(requirement.color)
                                .frame(width: 16)

                            Text(requirement.text)
                                .font(.system(size: 12))
                                .foregroundColor(
                                    requirement.isValid ?
                                    requirement.color :
                                        AppColors.Text.header(colorScheme).opacity(0.7)
                                )
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(AppColors.Text.header(colorScheme).opacity(0.05))
        )
    }
}

#Preview {
    PasswordStrengthView(password: "abc")
}
