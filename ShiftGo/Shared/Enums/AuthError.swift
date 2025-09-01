//
//  AuthError.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/9/1.
//

import Foundation
import FirebaseAuth

// MARK: - Errors
enum AuthError: Error, LocalizedError {
    case invalidEmail
    case weakPassword
    case emailAlreadyInUse
    case invalidCredentials
    case userNotFound
    case invalidInviteCode
    case invalidUserData
    case invalidCompanyData
    case networkError
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "無效的電子郵件格式"
        case .weakPassword:
            return "密碼強度不足，請使用至少6個字符"
        case .emailAlreadyInUse:
            return "此電子郵件已被註冊"
        case .invalidCredentials:
            return "電子郵件或密碼錯誤"
        case .userNotFound:
            return "找不到此用戶"
        case .invalidInviteCode:
            return "無效的邀請碼"
        case .invalidUserData:
            return "用戶資料格式錯誤"
        case .invalidCompanyData:
            return "公司資料格式錯誤"
        case .networkError:
            return "網路連接錯誤，請檢查您的網路設定"
        case .unknown:
            return "發生未知錯誤，請稍後重試"
        }
    }

    static func from(_ error: Error) -> AuthError {
        if let authError = error as? AuthError {
            return authError
        }

        if let nsError = error as NSError? {
            switch nsError.code {
            case AuthErrorCode.invalidEmail.rawValue:
                return .invalidEmail
            case AuthErrorCode.weakPassword.rawValue:
                return .weakPassword
            case AuthErrorCode.emailAlreadyInUse.rawValue:
                return .emailAlreadyInUse
            case AuthErrorCode.wrongPassword.rawValue, AuthErrorCode.invalidCredential.rawValue:
                return .invalidCredentials
            case AuthErrorCode.userNotFound.rawValue:
                return .userNotFound
            case AuthErrorCode.networkError.rawValue:
                return .networkError
            default:
                return .unknown
            }
        }

        return .unknown
    }
}
