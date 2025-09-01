//
//  SignInView.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/9/1.
//

import SwiftUI
import Combine

struct SignInView: View {
    @StateObject private var userManager = UserManager.shared
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme

    // Form State
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false

    // UI State
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var cancellables = Set<AnyCancellable>()

    var body: some View {
        ZStack {
            AppColors.Background.primary(colorScheme).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 30) {
                    headerView()
                    loginForm()
                    actionButtons()
                    dividerView()
                    alternativeOptions()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
            }
        }
        .navigationBarHidden(true)
        .alert("登入失敗", isPresented: $showError) {
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
            Image(systemName: "person.badge.key.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            Text("歡迎回來")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(AppColors.Text.header(colorScheme))

            Text("登入您的 ShiftGo 帳號")
                .font(.system(size: 16))
                .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.8))
        }
        .padding(.top, 40)
    }

    // MARK: - Login Form
    private func loginForm() -> some View {
        VStack(spacing: 20) {
            // Email Field
            VStack(alignment: .leading, spacing: 8) {
                Text("電子郵件")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppColors.Text.header(colorScheme))

                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.6))
                        .frame(width: 20)

                    TextField("輸入您的電子郵件", text: $email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                .textFieldStyle(SignInTextFieldStyle(colorScheme: colorScheme))
            }

            // Password Field
            VStack(alignment: .leading, spacing: 8) {
                Text("密碼")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppColors.Text.header(colorScheme))

                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.6))
                        .frame(width: 20)

                    Group {
                        if showPassword {
                            TextField("輸入您的密碼", text: $password)
                        } else {
                            SecureField("輸入您的密碼", text: $password)
                        }
                    }
                    .textContentType(.password)

                    Button(action: { showPassword.toggle() }) {
                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.6))
                    }
                }
                .textFieldStyle(SignInTextFieldStyle(colorScheme: colorScheme))
            }

            // Forgot Password
            HStack {
                Spacer()
                Button("忘記密碼？") {
                    // TODO: Implement forgot password
                }
                .font(.system(size: 14))
                .foregroundColor(.blue)
            }
        }
    }

    // MARK: - Action Buttons
    private func actionButtons() -> some View {
        VStack(spacing: 16) {
            // Login Button
            Button(action: handleSignIn) {
                HStack(spacing: 12) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 20))
                    }

                    Text(isLoading ? "登入中..." : "登入")
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

    // MARK: - Divider
    private func dividerView() -> some View {
        HStack {
            Rectangle()
                .fill(AppColors.Text.header(colorScheme).opacity(0.3))
                .frame(height: 1)

            Text("或")
                .font(.system(size: 14))
                .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.7))
                .padding(.horizontal, 16)

            Rectangle()
                .fill(AppColors.Text.header(colorScheme).opacity(0.3))
                .frame(height: 1)
        }
    }

    // MARK: - Alternative Options
    private func alternativeOptions() -> some View {
        VStack(spacing: 16) {
            // Guest Mode Button
            Button(action: enterGuestMode) {
                HStack(spacing: 12) {
                    Image(systemName: "person.crop.circle.dashed")
                        .font(.system(size: 16))

                    Text("訪客體驗")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.8))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(AppColors.Text.header(colorScheme).opacity(0.1))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppColors.Text.header(colorScheme).opacity(0.3), lineWidth: 1)
                )
            }
            .disabled(isLoading)

            // Sign Up Link
            HStack {
                Text("還沒有帳號？")
                    .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.7))

                NavigationLink("立即註冊", destination: SignUpView())
                    .foregroundColor(.blue)
                    .fontWeight(.semibold)
            }
            .font(.system(size: 16))
        }
    }

    // MARK: - Loading Overlay
    private func loadingOverlay() -> some View {
        ZStack {
            AppColors.Background.primary(colorScheme).ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.2)

                Text("登入中...")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppColors.Text.header(colorScheme))
            }
            .padding(24)
            .background(AppColors.Background.primary(colorScheme).opacity(0.8))
            .cornerRadius(16)
        }
    }

    // MARK: - Helper Properties
    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && email.contains("@")
    }

    // MARK: - Actions
    private func handleSignIn() {
        guard isFormValid else { return }

        isLoading = true
        errorMessage = ""

        userManager.signIn(email: email, password: password)
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
                    // Login successful - ContentView will handle navigation
                }
            )
            .store(in: &cancellables)
    }

    private func enterGuestMode() {
        isLoading = true

        userManager.enterGuestMode()
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
                    // Guest mode successful
                }
            )
            .store(in: &cancellables)
    }
}

// MARK: - Custom Text Field Style
struct SignInTextFieldStyle: TextFieldStyle {
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
        SignInView()
    }
}
