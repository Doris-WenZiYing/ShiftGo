//
//  LoginView.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/8/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var userManager: UserManager

    var body: some View {
        VStack(spacing: 30) {
            Text("ShiftGo")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Choose your role")
                .font(.title2)
                .foregroundColor(.secondary)

            VStack(spacing: 20) {
                Button(action: {
                    userManager.login(as: .employee)
                }) {
                    HStack {
                        Image(systemName: "person.fill")
                        Text("Login as Employee")
                    }
                    .font(.title3)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
                }

                Button(action: {
                    userManager.login(as: .boss)
                }) {
                    HStack {
                        Image(systemName: "person.badge.key.fill")
                        Text("Login as Boss")
                    }
                    .font(.title3)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.purple)
                    .cornerRadius(12)
                }
            }
        }
        .padding()
    }
}

#Preview {
    LoginView()
}
