//
//  JoinCompanyView.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/9/1.
//

import SwiftUI

struct JoinCompanyView: View {
    @Environment(\.dismiss) private var dismiss
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
                Color.black.ignoresSafeArea()

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
                        .foregroundColor(.white)
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
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("邀請碼")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)

                TextField("輸入 6 位邀請碼", text: $inviteCode)
                    .textCase(.uppercase)
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .multilineTextAlignment(.center)
//                    .textFieldStyle(CustomTextFieldStyle())
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
                .foregroundColor(.white)
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
                .foregroundColor(.white)

            Text("您已成功加入 \(companyName)")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)

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
