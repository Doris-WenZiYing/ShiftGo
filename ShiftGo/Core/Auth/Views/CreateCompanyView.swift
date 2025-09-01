//
//  CreateCompanyView.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/9/1.
//

import SwiftUI

struct CreateCompanyView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var userManager = UserManager.shared
    @State private var companyName = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var generatedInviteCode = ""
    @State private var showSuccess = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                if showSuccess {
                    successView()
                } else {
                    formView()
                }
            }
            .navigationTitle("建立組織")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") { dismiss() }
                        .foregroundColor(.white)
                }
            }
        }
        .alert("建立失敗", isPresented: $showError) {
            Button("確定") { }
        } message: {
            Text(errorMessage)
        }
    }

    private func formView() -> some View {
        VStack(spacing: 30) {
            VStack(spacing: 16) {
                Image(systemName: "building.2.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.orange)

                Text("建立您的組織")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("組織名稱")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)

                TextField("例：我的咖啡廳", text: $companyName)
//                    .textFieldStyle(CustomTextFieldStyle())
            }

            Button(action: createCompany) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                    }

                    Text(isLoading ? "建立中..." : "建立組織")
                        .font(.system(size: 18, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(!companyName.isEmpty ? Color.orange : Color.gray)
                .cornerRadius(12)
            }
            .disabled(companyName.isEmpty || isLoading)
        }
        .padding(.horizontal, 24)
    }

    private func successView() -> some View {
        VStack(spacing: 30) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)

            Text("組織建立成功！")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)

            VStack(spacing: 16) {
                Text("邀請碼")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))

                Text(generatedInviteCode)
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundColor(.orange)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)

                Text("將此邀請碼分享給您的員工")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }

            Button("開始使用") {
                dismiss()
            }
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.blue)
            .cornerRadius(12)
        }
        .padding(.horizontal, 24)
    }

    private func createCompany() {
        guard !companyName.isEmpty else { return }

        isLoading = true

        // 模擬創建公司 (後續實作真實功能)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.isLoading = false
            self.generatedInviteCode = self.generateInviteCode()
            self.showSuccess = true
        }
    }

    private func generateInviteCode() -> String {
        let chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in chars.randomElement()! })
    }
}

#Preview {
    CreateCompanyView()
}
