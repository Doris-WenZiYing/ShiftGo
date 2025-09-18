//
//  FirebaseEnums.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/9/18.
//

import Foundation

// MARK: - Firebase Error Types
enum FirebaseError: LocalizedError {
    case userNotFound
    case invalidCompany
    case permissionDenied
    case vacationSettingsNotFound
    case scheduleNotFound
    case networkError(String)
    case unknown(String)
    case invalidEmail
    case weakPassword
    case emailAlreadyInUse
    case invalidCredentials
    case invalidInviteCode
    case invalidUserData
    case invalidCompanyData
    case documentNotFound
    case quotaExceeded
    case invalidOperation

    var errorDescription: String? {
        switch self {
        case .userNotFound: return "error_user_not_found".localized
        case .invalidCompany: return "error_invalid_company".localized
        case .permissionDenied: return "error_permission_denied".localized
        case .vacationSettingsNotFound: return "error_vacation_settings_not_found".localized
        case .scheduleNotFound: return "error_schedule_not_found".localized
        case .networkError(let message): return String(format: "error_network".localized, message)
        case .unknown(let message): return String(format: "error_unknown".localized, message)
        case .invalidEmail: return "error_invalid_email".localized
        case .weakPassword: return "error_weak_password".localized
        case .emailAlreadyInUse: return "error_email_already_in_use".localized
        case .invalidCredentials: return "error_invalid_credentials".localized
        case .invalidInviteCode: return "error_invalid_invite_code".localized
        case .invalidUserData: return "error_invalid_user_data".localized
        case .invalidCompanyData: return "error_invalid_company_data".localized
        case .documentNotFound: return "error_document_not_found".localized
        case .quotaExceeded: return "error_quota_exceeded".localized
        case .invalidOperation: return "error_invalid_operation".localized
        }
    }

    var errorCode: String {
        switch self {
        case .userNotFound: return "USER_NOT_FOUND"
        case .invalidCompany: return "INVALID_COMPANY"
        case .permissionDenied: return "PERMISSION_DENIED"
        case .vacationSettingsNotFound: return "VACATION_SETTINGS_NOT_FOUND"
        case .scheduleNotFound: return "SCHEDULE_NOT_FOUND"
        case .networkError: return "NETWORK_ERROR"
        case .unknown: return "UNKNOWN_ERROR"
        case .invalidEmail: return "INVALID_EMAIL"
        case .weakPassword: return "WEAK_PASSWORD"
        case .emailAlreadyInUse: return "EMAIL_ALREADY_IN_USE"
        case .invalidCredentials: return "INVALID_CREDENTIALS"
        case .invalidInviteCode: return "INVALID_INVITE_CODE"
        case .invalidUserData: return "INVALID_USER_DATA"
        case .invalidCompanyData: return "INVALID_COMPANY_DATA"
        case .documentNotFound: return "DOCUMENT_NOT_FOUND"
        case .quotaExceeded: return "QUOTA_EXCEEDED"
        case .invalidOperation: return "INVALID_OPERATION"
        }
    }

    static func from(_ error: Error) -> FirebaseError {
        if let firebaseError = error as? FirebaseError {
            return firebaseError
        }

        let nsError = error as NSError
        let errorCode = nsError.code
        let errorMessage = nsError.localizedDescription

        // Map common Firebase error codes
        switch errorCode {
        case 7: return .permissionDenied
        case 5: return .documentNotFound
        case 8: return .quotaExceeded
        case 17007: return .emailAlreadyInUse
        case 17008, 17009: return .invalidEmail
        case 17026: return .weakPassword
        case 17011, 17004: return .invalidCredentials
        default: return .unknown(errorMessage)
        }
    }
}
