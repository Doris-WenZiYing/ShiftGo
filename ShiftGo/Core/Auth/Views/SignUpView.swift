//
//  SignUpView.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/9/1.
//

import SwiftUI
import Combine

struct SignUpView: View {
    @StateObject private var userManager = UserManager.shared
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme

    // Basic Info
    @State private var displayName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    @State private var showConfirmPassword = false

    // Role Selection
    @State private var selectedRole: UserRole = .employee

    // Organization Info
    @State private var organizationName = ""
    @State private var inviteCode = ""

    // UI State
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var cancellables = Set<AnyCancellable>()

    var body: some View {
        ZStack {
            AppColors.Background.primary(colorScheme).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    headerView()
                    basicInfoForm()
                    roleSelectionCard()
                    organizationCard()
                    actionButtons()
                    signInLink()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
            }
        }
        .navigationBarHidden(true)
        .alert("註冊失敗", isPresented: $showError) {
            Button("確定") { }
        } message: {
            Text(errorMessage)
        }
        .overlay {
            if isLoading {
                loadingOverlay()
            }
        }
    }

    // MARK: - Header
    private func headerView() -> some View {
        VStack(spacing: 16) {
            Image(systemName: "person.badge.plus.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)

            Text("建立帳號")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(AppColors.Text.header(colorScheme))

            Text("開始使用 ShiftGo 管理您的班表")
                .font(.system(size: 16))
                .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }

    // MARK: - Basic Info Form
    private func basicInfoForm() -> some View {
        VStack(spacing: 20) {
            sectionHeader("基本資訊", icon: "person.fill")

            VStack(spacing: 16) {
                // Display Name
                customTextField(
                    title: "顯示名稱",
                    text: $displayName,
                    icon: "person.fill",
                    placeholder: "輸入您的姓名"
                )

                // Email
                customTextField(
                    title: "電子郵件",
                    text: $email,
                    icon: "envelope.fill",
                    placeholder: "輸入電子郵件地址",
                    keyboardType: .emailAddress
                )

                // Password
                customSecureField(
                    title: "密碼",
                    text: $password,
                    showPassword: $showPassword,
                    placeholder: "設定您的密碼"
                )

                // Confirm Password
                customSecureField(
                    title: "確認密碼",
                    text: $confirmPassword,
                    showPassword: $showConfirmPassword,
                    placeholder: "再次輸入密碼"
                )

                // Password validation
                if !password.isEmpty || !confirmPassword.isEmpty {
                    passwordValidationView()
                }
            }
        }
    }

    // MARK: - Role Selection
    private func roleSelectionCard() -> some View {
        VStack(spacing: 16) {
            sectionHeader("選擇身分", icon: "person.2.fill")

            HStack(spacing: 12) {
                roleButton(.boss, "我是老闆", "管理員工排班", .orange)
                roleButton(.employee, "我是員工", "申請排休", .green)
            }
        }
    }

    private func roleButton(_ role: UserRole, _ title: String, _ subtitle: String, _ color: Color) -> some View {
        Button(action: { selectedRole = role }) {
            VStack(spacing: 12) {
                Image(systemName: role == .boss ? "crown.fill" : "person.fill")
                    .font(.system(size: 24))
                    .foregroundColor(selectedRole == role ? .white : color)

                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.Text.header(colorScheme))

                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(selectedRole == role ? color : AppColors.Text.header(colorScheme).opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(selectedRole == role ? Color.clear : color.opacity(0.5), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.easeInOut(duration: 0.2), value: selectedRole)
    }

    // MARK: - Organization Card
    private func organizationCard() -> some View {
        VStack(spacing: 16) {
            if selectedRole == .boss {
                bossOrganizationCard()
            } else {
                employeeInviteCard()
            }
        }
    }

    private func bossOrganizationCard() -> some View {
        VStack(spacing: 16) {
            sectionHeader("建立組織", icon: "building.2.fill")

            VStack(spacing: 16) {
                customTextField(
                    title: "組織名稱",
                    text: $organizationName,
                    icon: "building.2.fill",
                    placeholder: "例：我的咖啡廳、ABC 餐廳"
                )

                infoCard(
                    title: "老闆權限",
                    items: [
                        "建立和管理員工帳號",
                        "設定排休規則",
                        "生成工作班表",
                        "查看員工統計"
                    ],
                    color: .orange
                )
            }
        }
    }

    private func employeeInviteCard() -> some View {
        VStack(spacing: 16) {
            sectionHeader("加入組織", icon: "key.fill")

            VStack(spacing: 16) {
                customTextField(
                    title: "邀請碼",
                    text: $inviteCode,
                    icon: "key.fill",
                    placeholder: "輸入老闆提供的邀請碼"
                )

                infoCard(
                    title: "員工功能",
                    items: [
                        "申請排休",
                        "查看工作班表",
                        "追蹤工作時數",
                        "申請請假"
                    ],
                    color: .green
                )
            }
        }
    }

    // MARK: - Action Buttons
    private func actionButtons() -> some View {
        VStack(spacing: 16) {
            Button(action: handleSignUp) {
                HStack(spacing: 12) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                    }

                    Text(isLoading ? "註冊中..." : "建立帳號")
                        .font(.system(size: 18, weight: .semibold))
                }
                .foregroundColor(AppColors.Text.header(colorScheme))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(isFormValid ? Color.blue : Color.gray)
                .cornerRadius(12)
            }
            .disabled(!isFormValid || isLoading)
            .animation(.easeInOut(duration: 0.2), value: isFormValid)
        }
    }

    private func signInLink() -> some View {
        HStack {
            Text("已有帳號？")
                .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.7))

            Button("立即登入") {
                dismiss()
            }
            .foregroundColor(.blue)
            .fontWeight(.semibold)
        }
        .font(.system(size: 16))
    }

    // MARK: - Helper Views
    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.blue)

            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppColors.Text.header(colorScheme))

            Spacer()
        }
    }

    private func customTextField(
        title: String,
        text: Binding<String>,
        icon: String,
        placeholder: String,
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.8))

            HStack {
                Image(systemName: icon)
                    .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.6))
                    .frame(width: 20)

                TextField(placeholder, text: text)
                    .keyboardType(keyboardType)
                    .autocapitalization(keyboardType == .emailAddress ? .none : .words)
                    .disableAutocorrection(keyboardType == .emailAddress)
            }
            .textFieldStyle(SignUpTextFieldStyle(colorScheme: colorScheme))
        }
    }

    private func customSecureField(
        title: String,
        text: Binding<String>,
        showPassword: Binding<Bool>,
        placeholder: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.8))

            HStack {
                Image(systemName: "lock.fill")
                    .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.6))
                    .frame(width: 20)

                Group {
                    if showPassword.wrappedValue {
                        TextField(placeholder, text: text)
                    } else {
                        SecureField(placeholder, text: text)
                    }
                }

                Button(action: { showPassword.wrappedValue.toggle() }) {
                    Image(systemName: showPassword.wrappedValue ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.6))
                }
            }
            .textFieldStyle(SignUpTextFieldStyle(colorScheme: colorScheme))
        }
    }

    private func passwordValidationView() -> some View {
        VStack(alignment: .leading, spacing: 4) {
            validationItem("至少 6 個字符", isValid: password.count >= 6)
            validationItem("密碼相符", isValid: !confirmPassword.isEmpty && password == confirmPassword)
        }
        .padding(.horizontal, 16)
    }

    private func validationItem(_ text: String, isValid: Bool) -> some View {
        HStack(spacing: 8) {
            Image(systemName: isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 12))
                .foregroundColor(isValid ? .green : .red)

            Text(text)
                .font(.system(size: 12))
                .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.7))
        }
    }

    private func infoCard(title: String, items: [String], color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)

            VStack(alignment: .leading, spacing: 6) {
                ForEach(items, id: \.self) { item in
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(color)

                        Text(item)
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.8))
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }

    // MARK: - Loading Overlay
    private func loadingOverlay() -> some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.2)

                Text("建立帳號中...")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppColors.Text.header(colorScheme))
            }
            .padding(24)
            .background(Color.black.opacity(0.8))
            .cornerRadius(16)
        }
    }

    // MARK: - Validation
    private var isFormValid: Bool {
        !displayName.isEmpty &&
        !email.isEmpty &&
        email.contains("@") &&
        password.count >= 6 &&
        password == confirmPassword &&
        organizationFormValid
    }

    private var organizationFormValid: Bool {
        if selectedRole == .boss {
            return !organizationName.isEmpty
        } else {
            return !inviteCode.isEmpty
        }
    }

    // MARK: - Actions
    private func handleSignUp() {
        guard isFormValid else { return }

        isLoading = true
        errorMessage = ""

        let authPublisher: AnyPublisher<Void, Error>

        if selectedRole == .boss {
            authPublisher = userManager.signUpAsBoss(
                email: email,
                password: password,
                name: displayName,
                orgName: organizationName
            )
        } else {
            authPublisher = userManager.signUpAsEmployee(
                email: email,
                password: password,
                name: displayName,
                inviteCode: inviteCode
            )
        }

        authPublisher
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    self.isLoading = false
                    switch completion {
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                        self.showError = true
                    case .finished:
                        break
                    }
                },
                receiveValue: {
                    // Registration successful - ContentView will handle navigation
                }
            )
            .store(in: &cancellables)
    }
}

// MARK: - Custom Text Field Style
struct SignUpTextFieldStyle: TextFieldStyle {

    let colorScheme: ColorScheme

    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(AppColors.Text.header(colorScheme).opacity(0.1))
            .cornerRadius(12)
            .foregroundColor(AppColors.Text.header(colorScheme))
    }
}

#Preview {
    NavigationView {
        SignUpView()
    }
}

#Preview {
    SignUpView()
}
