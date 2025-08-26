//
//  UserManager.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/8/25.
//


import SwiftUI
import Combine

class UserManager: ObservableObject {
    @AppStorage("userRole") var userRole: String = UserRole.employee.rawValue {
        didSet {
            objectWillChange.send()
        }
    }

    @Published var isLoggedIn: Bool = true // 模擬登入狀態

    var currentRole: UserRole {
        UserRole(rawValue: userRole) ?? .employee
    }

    // 切換角色（用於測試）
    func switchRole() {
        userRole = currentRole == .employee ? UserRole.boss.rawValue : UserRole.employee.rawValue
    }

    // 登出
    func logout() {
        isLoggedIn = false
    }

    // 登入
    func login(as role: UserRole) {
        userRole = role.rawValue
        isLoggedIn = true
    }
}
