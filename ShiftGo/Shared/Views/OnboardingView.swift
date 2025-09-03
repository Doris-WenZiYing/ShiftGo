//
//  OnboardingView.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/9/3.
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var animationOffset: CGFloat = 0

    var body: some View {
        ZStack {
            // 背景漸層
            LinearGradient(
                gradient: Gradient(colors: [
                    AppColors.Background.primary(colorScheme),
                    AppColors.Background.primary(colorScheme).opacity(0.8)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // Logo 和標題
                VStack(spacing: 20) {
                    // 動畫 Logo
                    Image(systemName: "calendar.badge.checkmark")
                        .font(.system(size: 80, weight: .light))
                        .foregroundColor(.blue)
                        .scaleEffect(1.0 + sin(animationOffset) * 0.1)
                        .animation(
                            Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                            value: animationOffset
                        )

                    Text("ShiftGo")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.Text.header(colorScheme))

                    Text("智慧排班助手")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.8))
                }

                Spacer()

                // 載入指示器
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .scaleEffect(1.2)

                    Text("正在載入...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.7))
                }

                Spacer()

                // 版本資訊
                VStack(spacing: 8) {
                    Text("Version 1.0.0")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.5))

                    Text("© 2025 ShiftGo. All rights reserved.")
                        .font(.system(size: 10))
                        .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.4))
                }
                .padding(.bottom, 32)
            }
            .padding(.horizontal, 40)
        }
        .onAppear {
            animationOffset = 1.0
        }
    }
}

#Preview {
    OnboardingView()
}
