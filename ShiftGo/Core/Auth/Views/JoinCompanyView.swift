//
//  JoinCompanyView.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/9/1.
//

import SwiftUI

struct JoinCompanyView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var userManager = UserManager.shared
    @State private var inviteCode = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var showSuccess = false
    @State private var companyName = ""

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.Background.primary(colorScheme).ignoresSafeArea()

                if showSuccess {
                    successView()
                } else {
                    formView()
                }
            }
            .navigationTitle("加入組織")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") { dismiss() }
                        .foregroundColor(AppColors.Text.header(colorScheme))
                }
            }
        }
        .alert("加入失敗", isPresented: $showError) {
            Button("確定") { }
        } message: {
            Text(errorMessage)
        }
    }

    private func formView() -> some View {
        VStack(spacing: 30) {
            VStack(spacing: 16) {
                Image(systemName: "person.badge.plus.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)

                Text("加入組織")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppColors.Text.header(colorScheme))
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("邀請碼")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppColors.Text.header(colorScheme))

                TextField("輸入 6 位邀請碼", text: $inviteCode)
                    .textCase(.uppercase)
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .multilineTextAlignment(.center)
                    .textFieldStyle(CustomTextFieldStyle(colorScheme: colorScheme))
                    .onChange(of: inviteCode) { _, newValue in
                        let filtered = String(newValue.prefix(6).filter { $0.isLetter || $0.isNumber })
                        if filtered != newValue {
                            inviteCode = filtered
                        }
                    }
            }

            Button(action: joinCompany) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 20))
                    }

                    Text(isLoading ? "加入中..." : "加入組織")
                        .font(.system(size: 18, weight: .semibold))
                }
                .foregroundColor(AppColors.Text.header(colorScheme))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(inviteCode.count == 6 ? Color.green : Color.gray)
                .cornerRadius(12)
            }
            .disabled(inviteCode.count != 6 || isLoading)
        }
        .padding(.horizontal, 24)
    }

    private func successView() -> some View {
        VStack(spacing: 30) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)

            Text("加入成功！")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(AppColors.Text.header(colorScheme))

            Text("您已成功加入 \(companyName)")
                .font(.system(size: 16))
                .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.8))
                .multilineTextAlignment(.center)

            Button("開始使用") {
                dismiss()
            }
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(AppColors.Text.header(colorScheme))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.blue)
            .cornerRadius(12)
        }
        .padding(.horizontal, 24)
    }

    private func joinCompany() {
        guard inviteCode.count == 6 else { return }

        isLoading = true

        // 模擬加入公司 (後續實作真實功能)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.isLoading = false
            self.companyName = "示範咖啡廳"
            self.showSuccess = true
        }
    }
}

#Preview {
    JoinCompanyView()
}
