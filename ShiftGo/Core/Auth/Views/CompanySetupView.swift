//
//  CompanySetupView.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/9/1.
//

import SwiftUI

struct CompanySetupView: View {
    @StateObject private var userManager = UserManager.shared
    @State private var showingCreateCompany = false
    @State private var showingJoinCompany = false
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            AppColors.Background.primary(colorScheme).ignoresSafeArea()

            VStack(spacing: 40) {
                headerView()
                setupOptions()
                footerView()
            }
            .padding(.horizontal, 24)
        }
        .sheet(isPresented: $showingCreateCompany) {
            CreateCompanyView()
        }
        .sheet(isPresented: $showingJoinCompany) {
            JoinCompanyView()
        }
    }

    private func headerView() -> some View {
        VStack(spacing: 20) {
            Image(systemName: "building.2.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)

            VStack(spacing: 8) {
                Text("設置您的工作場所")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(AppColors.Text.header(colorScheme))

                Text("歡迎使用 ShiftGo！")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.8))

                Text("請選擇您要建立新組織還是加入現有組織")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.6))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 60)
    }

    private func setupOptions() -> some View {
        VStack(spacing: 24) {
            // Create Company Option
            Button(action: { showingCreateCompany = true }) {
                setupOptionCard(
                    title: "建立新組織",
                    subtitle: "我是老闆，要建立新的工作場所",
                    icon: "plus.circle.fill",
                    color: .orange
                )
            }
            .buttonStyle(PlainButtonStyle())

            // Join Company Option
            Button(action: { showingJoinCompany = true }) {
                setupOptionCard(
                    title: "加入現有組織",
                    subtitle: "我是員工，要加入老闆的組織",
                    icon: "person.badge.plus.fill",
                    color: .green
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    private func setupOptionCard(title: String, subtitle: String, icon: String, color: Color) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(color)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppColors.Text.header(colorScheme))

                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.8))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.6))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.Text.header(colorScheme).opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }

    private func footerView() -> some View {
        VStack(spacing: 16) {
            // Sign Out Button
            Button(action: signOut) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.left.circle")
                        .font(.system(size: 16))

                    Text("登出")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.7))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(AppColors.Text.header(colorScheme).opacity(0.1))
                )
            }

            // User Info
            if let user = userManager.currentUser {
                VStack(spacing: 4) {
                    Text("登入身分：\(user.name)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.8))

                    Text(user.email)
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.6))
                }
            }
        }
    }

    private func signOut() {
        do {
            try userManager.signOut()
        } catch {
            print("Sign out error: \(error)")
        }
    }
}

#Preview {
    CompanySetupView()
}
