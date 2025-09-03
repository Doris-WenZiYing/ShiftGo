//
//  PasswordValidator.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/9/3.
//

import Foundation
import SwiftUI
// MARK: - 密碼驗證器
class PasswordValidator: ObservableObject {
    enum PasswordStrength: CaseIterable {
        case weak
        case medium
        case strong

        var color: Color {
            switch self {
            case .weak: return .red
            case .medium: return .orange
            case .strong: return .green
            }
        }

        var text: String {
            switch self {
            case .weak: return "Week"
            case .medium: return "Medium"
            case .strong: return "Strong"
            }
        }

        var progress: Double {
            switch self {
            case .weak: return 0.33
            case .medium: return 0.66
            case .strong: return 1.0
            }
        }
    }

    struct PasswordRequirement {
        let text: String
        let isValid: Bool
        let isRequired: Bool // 🔥 新增：區分必需和建議項目

        var icon: String {
            isValid ? "checkmark.circle.fill" : "xmark.circle.fill"
        }

        var color: Color {
            isValid ? .green : (isRequired ? .red : .orange)
        }
    }

    // MARK: - 密碼驗證方法

    /// 驗證密碼是否符合所有要求
    static func isValidPassword(_ password: String) -> Bool {
        return password.count >= 6 &&
        password.count <= 20 &&
        containsUppercase(password) &&
        containsLowercase(password)
    }

    /// 獲取密碼強度
    static func getPasswordStrength(_ password: String) -> PasswordStrength {
        var score = 0

        // 長度檢查 (6-20)
        if password.count >= 6 && password.count <= 20 {
            score += 1
        }

        // 包含大寫字母
        if containsUppercase(password) {
            score += 1
        }

        // 包含小寫字母
        if containsLowercase(password) {
            score += 1
        }

        // 額外加分項
        if containsNumber(password) {
            score += 1
        }

        if containsSpecialCharacter(password) {
            score += 1
        }

        // 長度加分
        if password.count >= 12 {
            score += 1
        }

        switch score {
        case 0...2:
            return .weak
        case 3...4:
            return .medium
        default:
            return .strong
        }
    }

    /// 獲取密碼要求列表
    static func getPasswordRequirements(_ password: String) -> [PasswordRequirement] {
        return [
            PasswordRequirement(
                text: "長度 6-20 字符",
                isValid: password.count >= 6 && password.count <= 20,
                isRequired: true
            ),
            PasswordRequirement(
                text: "包含大寫字母 (A-Z)",
                isValid: containsUppercase(password),
                isRequired: true
            ),
            PasswordRequirement(
                text: "包含小寫字母 (a-z)",
                isValid: containsLowercase(password),
                isRequired: true
            ),
            PasswordRequirement(
                text: "建議：包含數字 (0-9)",
                isValid: containsNumber(password),
                isRequired: false
            ),
            PasswordRequirement(
                text: "建議：包含特殊字符 (!@#$%^&*)",
                isValid: containsSpecialCharacter(password),
                isRequired: false
            )
        ]
    }

    // MARK: - Private Helper Methods

    private static func containsUppercase(_ password: String) -> Bool {
        return password.range(of: "[A-Z]", options: .regularExpression) != nil
    }

    private static func containsLowercase(_ password: String) -> Bool {
        return password.range(of: "[a-z]", options: .regularExpression) != nil
    }

    private static func containsNumber(_ password: String) -> Bool {
        return password.range(of: "[0-9]", options: .regularExpression) != nil
    }

    private static func containsSpecialCharacter(_ password: String) -> Bool {
        return password.range(of: "[!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>\\/?]", options: .regularExpression) != nil
    }
}
