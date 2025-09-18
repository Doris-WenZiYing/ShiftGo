//
//  ContentView.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/8/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var userManager: UserManager
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Group {
            if appState.isInitializing {
                OnboardingView()
            } else {
                AppFlowCoordinator()
            }
        }
        .animation(.easeInOut(duration: 0.5), value: appState.isInitializing)
    }
}

// MARK: - App Flow Coordinator
struct AppFlowCoordinator: View {
    @EnvironmentObject var userManager: UserManager

    var body: some View {
        Group {
            if userManager.isLoggedIn {
                AuthenticatedView()
            } else {
                AuthenticationView()
            }
        }
        .transition(.opacity)
    }
}

// MARK: - Authenticated Views
struct AuthenticatedView: View {
    @EnvironmentObject var userManager: UserManager

    var body: some View {
        Group {
            if userManager.isGuest {
                GuestModeView()
            } else if userManager.currentCompany != nil {
                MainAppView()
            } else {
                CompanySetupView()
            }
        }
    }
}

// MARK: - Authentication View
struct AuthenticationView: View {
    var body: some View {
        LoginView()
    }
}

// MARK: - Guest Mode View
struct GuestModeView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var userManager: UserManager

    var body: some View {
        VStack(spacing: 0) {
            GuestModeHeader()
            MainAppView()
                .overlay(GuestLimitationsOverlay(), alignment: .bottom)
        }
    }
}

// MARK: - Guest Mode Components
struct GuestModeHeader: View {
    @EnvironmentObject var userManager: UserManager

    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "person.crop.circle.dashed")
                    .font(.system(size: 14))
                    .foregroundColor(.orange)

                Text("訪客模式")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.orange)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(16)

            Spacer()

            Button("註冊解鎖") {
                signOutToRegistration()
            }
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.blue)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(16)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }

    private func signOutToRegistration() {
        try? userManager.signOut()
    }
}

struct GuestLimitationsOverlay: View {
    @EnvironmentObject var userManager: UserManager

    var body: some View {
        VStack {
            Spacer()

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("訪客模式限制")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.orange)

                    Text("無法儲存資料・功能受限")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.8))
                }

                Spacer()

                Button("立即註冊") {
                    try? userManager.signOut()
                }
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue)
                .cornerRadius(8)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
        .environmentObject(ThemeManager())
        .environmentObject(UserManager.shared)
}
