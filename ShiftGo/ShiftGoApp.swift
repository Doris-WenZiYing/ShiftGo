//
//  ShiftGoApp.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/8/25.
//

import SwiftUI
import FirebaseCore
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        // Firebase 配置
        FirebaseApp.configure()

        // 通知權限請求
        requestNotificationPermission()

        print("🚀 ShiftGo App initialized successfully")
        return true
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            if granted {
                print("✅ Notification permission granted")
            } else if let error = error {
                print("❌ Notification permission error: \(error)")
            }
        }
    }
}

@main
struct ShiftGoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(appState.themeManager)
                .environmentObject(appState.userManager)
                .preferredColorScheme(appState.themeManager.preferredColorScheme)
        }
    }
}

// MARK: - App State Manager
@MainActor
class AppState: ObservableObject {
    let themeManager = ThemeManager()
    let userManager = UserManager.shared

    @Published var isInitializing = true

    init() {
        // 設置初始化完成延遲
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 0.5)) {
                self.isInitializing = false
            }
        }
    }
}
