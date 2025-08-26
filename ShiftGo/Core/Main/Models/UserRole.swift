//
//  UserRole.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/8/25.
//

import Foundation

enum UserRole: String, CaseIterable {
    case employee = "employee"
    case boss = "boss"

    var displayName: String {
        switch self {
        case .employee: return "Employee"
        case .boss: return "Boss"
        }
    }
}
