//
//  MoreView.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/8/25.
//

import SwiftUI
import Combine

struct MoreView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var userManager: UserManager
    @Environment(\.colorScheme) var colorScheme

    // Invite code related states
    @State private var organizationInviteCode = ""
    @State private var isLoadingInviteCode = false
    @State private var showingInviteCodeSheet = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: DesignTokens.Spacing.xl) {
                    profileSection()

                    if userManager.isLoggedIn {
                        if userManager.currentRole == .boss {
                            managementSection()
                        } else {
                            employeeSection()
                        }
                    }

                    preferencesSection()
                    supportSection()

                    if userManager.isLoggedIn || userManager.isGuest {
                        logoutSection()
                    }

                    Spacer(minLength: DesignTokens.Spacing.xxxl)
                }
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.top, DesignTokens.Spacing.lg)
            }
            .background(AppColors.Background.primary(colorScheme))
            .navigationTitle("Settings")
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingInviteCodeSheet) {
            InviteCodeSheet(inviteCode: $organizationInviteCode)
                .presentationDetents([.medium])
        }
        .alert("Error", isPresented: $showingErrorAlert) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            if userManager.isLoggedIn && userManager.currentRole == .boss {
                preloadInviteCode()
            }
        }
    }

    // MARK: - Profile Section
    private func profileSection() -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            SectionHeader("Profile")

            PrimaryCard {
                HStack(spacing: DesignTokens.Spacing.lg) {
                    // Avatar
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [getUserIconColor(), getUserIconColor().opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: getUserIcon())
                                .font(.system(size: 28))
                                .foregroundColor(.white)
                        )

                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                        Text(getUserDisplayName())
                            .font(DesignTokens.Typography.headline)
                            .foregroundColor(AppColors.Text.header(colorScheme))

                        Text(getUserStatusTitle())
                            .font(DesignTokens.Typography.captionMedium)
                            .foregroundColor(getUserIconColor())

                        if let company = userManager.currentCompany {
                            Text(company.name)
                                .font(DesignTokens.Typography.caption)
                                .foregroundColor(.secondary)
                        } else if userManager.isGuest {
                            Text("Guest mode - Limited features")
                                .font(DesignTokens.Typography.caption)
                                .foregroundColor(.orange)
                        }
                    }

                    Spacer()

                    if userManager.isGuest {
                        PrimaryButton("Switch", style: .secondary) {
                            userManager.switchRole()
                        }
                        .frame(width: 80)
                    }
                }
                .padding(DesignTokens.Spacing.lg)
            }
        }
    }

    // MARK: - Management Section (Boss)
    private func managementSection() -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            SectionHeader("Management")

            PrimaryCard {
                VStack(spacing: 0) {
                    FeatureRow(
                        icon: "key.fill",
                        title: "Organization Invite Code",
                        subtitle: "Manage employee access",
                        iconColor: AppColors.Theme.primary
                    ) {
                        loadInviteCode()
                    }

                    Divider().padding(.leading, 56)

                    FeatureRow(
                        icon: "person.2.fill",
                        title: "Employee Management",
                        subtitle: "View and manage staff",
                        iconColor: AppColors.Theme.secondary
                    ) {
                        // Employee management functionality
                    }

                    Divider().padding(.leading, 56)

                    FeatureRow(
                        icon: "calendar.badge.clock",
                        title: "Schedule Management",
                        subtitle: "Set and adjust schedules",
                        iconColor: .green
                    ) {
                        // Schedule management functionality
                    }

                    Divider().padding(.leading, 56)

                    FeatureRow(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Analytics & Reports",
                        subtitle: "View operational data",
                        iconColor: .purple
                    ) {
                        // Analytics functionality
                    }
                }
            }
        }
    }

    // MARK: - Employee Section
    private func employeeSection() -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            SectionHeader("Personal Settings")

            PrimaryCard {
                VStack(spacing: 0) {
                    FeatureRow(
                        icon: "person.circle.fill",
                        title: "Profile",
                        subtitle: "Edit personal information",
                        iconColor: AppColors.Theme.primary
                    ) {
                        // Profile functionality
                    }

                    Divider().padding(.leading, 56)

                    FeatureRow(
                        icon: "calendar.badge.plus",
                        title: "Leave Requests",
                        subtitle: "Request time off and shifts",
                        iconColor: .green
                    ) {
                        // Leave request functionality
                    }

                    Divider().padding(.leading, 56)

                    FeatureRow(
                        icon: "clock.badge.checkmark.fill",
                        title: "Time Tracking",
                        subtitle: "View work hours",
                        iconColor: .orange
                    ) {
                        // Time tracking functionality
                    }
                }
            }
        }
    }

    // MARK: - Preferences Section
    private func preferencesSection() -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            SectionHeader("Preferences")

            PrimaryCard {
                VStack(spacing: 0) {
                    FeatureRow(
                        icon: "display",
                        title: "Display Settings",
                        subtitle: "Adjust interface display",
                        iconColor: AppColors.Theme.primary
                    ) {
                        // Display settings functionality
                    }

                    Divider().padding(.leading, 56)

                    // Dark Mode Toggle Row
                    HStack(spacing: DesignTokens.Spacing.lg) {
                        Circle()
                            .fill(Color.indigo.opacity(0.1))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "moon.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.indigo)
                            )

                        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                            Text("Dark Mode")
                                .font(DesignTokens.Typography.bodyMedium)
                                .foregroundColor(AppColors.Text.header(colorScheme))

                            Text(themeManager.currentTheme.displayName)
                                .font(DesignTokens.Typography.small)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        NavigationLink(destination: ThemeSelectionView(themeManager: themeManager)) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(DesignTokens.Spacing.lg)

                    Divider().padding(.leading, 56)

                    FeatureRow(
                        icon: "globe",
                        title: "Language",
                        subtitle: "Choose display language",
                        iconColor: .red
                    ) {
                        // Language settings functionality
                    }

                    Divider().padding(.leading, 56)

                    FeatureRow(
                        icon: "bell.fill",
                        title: "Notifications",
                        subtitle: "Manage push notifications",
                        iconColor: .orange
                    ) {
                        // Notification settings functionality
                    }
                }
            }
        }
    }

    // MARK: - Support Section
    private func supportSection() -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            SectionHeader("Help & Support")

            PrimaryCard {
                VStack(spacing: 0) {
                    FeatureRow(
                        icon: "questionmark.circle.fill",
                        title: "Help Center",
                        subtitle: "FAQs and user guides",
                        iconColor: AppColors.Theme.primary
                    ) {
                        // Help center functionality
                    }

                    Divider().padding(.leading, 56)

                    FeatureRow(
                        icon: "envelope.fill",
                        title: "Contact Us",
                        subtitle: "Feedback and customer service",
                        iconColor: .green
                    ) {
                        // Contact us functionality
                    }

                    Divider().padding(.leading, 56)

                    FeatureRow(
                        icon: "doc.text.fill",
                        title: "Terms of Service",
                        subtitle: "Terms and privacy policy",
                        iconColor: .gray
                    ) {
                        // Terms functionality
                    }
                }
            }
        }
    }

    // MARK: - Logout Section
    private func logoutSection() -> some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            PrimaryButton(
                userManager.isGuest ? "Exit Guest Mode" : "Sign Out",
                icon: "power",
                style: .destructive
            ) {
                showLogoutAlert()
            }

            // Version info
            VStack(spacing: DesignTokens.Spacing.xs) {
                Text("ShiftGo")
                    .font(DesignTokens.Typography.smallMedium)
                    .foregroundColor(.secondary)

                Text("Version 1.0.0")
                    .font(DesignTokens.Typography.small)
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - Helper Methods
    private func getUserIcon() -> String {
        if userManager.isGuest {
            return "person.crop.circle.dashed"
        } else {
            switch userManager.currentRole {
            case .boss:
                return "crown.fill"
            case .employee:
                return "person.fill"
            }
        }
    }

    private func getUserIconColor() -> Color {
        if userManager.isGuest {
            return .orange
        } else {
            switch userManager.currentRole {
            case .boss:
                return .purple
            case .employee:
                return AppColors.Theme.primary
            }
        }
    }

    private func getUserStatusTitle() -> String {
        if userManager.isGuest {
            return "Guest Mode"
        } else {
            switch userManager.currentRole {
            case .boss:
                return "Manager"
            case .employee:
                return "Employee"
            }
        }
    }

    private func getUserDisplayName() -> String {
        if let user = userManager.currentUser {
            return user.name
        } else {
            return "Not signed in"
        }
    }

    private func showLogoutAlert() {
        let alert = UIAlertController(
            title: userManager.isGuest ? "Exit Guest Mode" : "Sign Out",
            message: userManager.isGuest ? "Are you sure you want to exit guest mode?" : "Are you sure you want to sign out?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: userManager.isGuest ? "Exit" : "Sign Out", style: .destructive) { _ in
            do {
                try userManager.signOut()
            } catch {
                print("Logout error: \(error)")
            }
        })

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(alert, animated: true)
        }
    }

    // MARK: - Invite Code Methods
    private func preloadInviteCode() {
        guard let currentCompany = userManager.currentCompany else { return }
        organizationInviteCode = currentCompany.inviteCode
    }

    private func loadInviteCode() {
        guard userManager.isLoggedIn else {
            showError("Please sign in first")
            return
        }

        guard userManager.currentRole == .boss else {
            showError("Only managers can view the invite code")
            return
        }

        guard let currentCompany = userManager.currentCompany else {
            showError("Organization information not found")
            return
        }

        organizationInviteCode = currentCompany.inviteCode

        if !organizationInviteCode.isEmpty {
            showingInviteCodeSheet = true
        } else {
            showError("Failed to load invite code")
        }
    }

    private func showError(_ message: String) {
        errorMessage = message
        showingErrorAlert = true
    }
}

// MARK: - Invite Code Sheet (English Version)
struct InviteCodeSheet: View {
    @Binding var inviteCode: String
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var showingCopiedAlert = false

    var body: some View {
        NavigationView {
            VStack(spacing: DesignTokens.Spacing.xxxl) {
                Spacer()

                // Icon
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppColors.Theme.primary, AppColors.Theme.secondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: "key.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    )

                VStack(spacing: DesignTokens.Spacing.md) {
                    Text("Organization Invite Code")
                        .font(DesignTokens.Typography.largeTitle)
                        .foregroundColor(AppColors.Text.header(colorScheme))

                    Text("Share this invite code with employees to join your organization")
                        .font(DesignTokens.Typography.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, DesignTokens.Spacing.xl)
                }

                PrimaryCard(backgroundColor: AppColors.Theme.primary.opacity(0.1)) {
                    VStack(spacing: DesignTokens.Spacing.lg) {
                        Text(inviteCode.isEmpty ? "Loading..." : inviteCode)
                            .font(.system(size: 32, weight: .bold, design: .monospaced))
                            .foregroundColor(inviteCode.isEmpty ? .gray : AppColors.Theme.primary)
                            .padding()

                        if !inviteCode.isEmpty {
                            PrimaryButton("Copy Invite Code", icon: "doc.on.doc.fill") {
                                copyInviteCode()
                            }
                        }
                    }
                    .padding(DesignTokens.Spacing.xl)
                }

                Spacer()
            }
            .padding(.horizontal, DesignTokens.Spacing.xl)
            .background(AppColors.Background.primary(colorScheme))
            .navigationTitle("Invite Code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.Theme.primary)
                }
            }
        }
        .alert("Copied", isPresented: $showingCopiedAlert) {
            Button("OK") { }
        } message: {
            Text("Invite code has been copied to clipboard")
        }
    }

    private func copyInviteCode() {
        guard !inviteCode.isEmpty else { return }

        UIPasteboard.general.string = inviteCode
        showingCopiedAlert = true

        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
}

#Preview {
    MoreView()
        .environmentObject(ThemeManager())
        .environmentObject(UserManager.shared)
}
