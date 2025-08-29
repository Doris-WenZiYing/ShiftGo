//
//  BossManagementSheet.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/8/27.
//

import SwiftUI

struct BossManagementSheet: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var isPresented: Bool
    @Binding var selectedAction: BossAction?
    @Binding var isVacationPublished: Bool
    @Binding var employeeVacationCount: Int
    @Binding var isLoading: Bool

    private let currentMonth = Calendar.current.component(.month, from: Date())
    private let currentYear = Calendar.current.component(.year, from: Date())

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    headerSection()

                    // Status Overview
                    statusOverviewSection()

                    // Quick Actions
                    quickActionsSection()

                    // Management Options
                    managementOptionsSection()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
            }
            .background(AppColors.Background.primary(colorScheme))
            .navigationTitle("管理中心")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("關閉") {
                        isPresented = false
                    }
                    .foregroundColor(AppColors.Text.header(colorScheme))
                }
            }
        }
    }

    // MARK: - Header Section
    private func headerSection() -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "crown.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.yellow)

                VStack(alignment: .leading, spacing: 4) {
                    Text("管理中心")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppColors.Text.header(colorScheme))

                    Text("\(currentYear)年\(currentMonth)月 排班管理")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.7))
                }

                Spacer()

                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.Calendar.saturday))
                        .scaleEffect(0.8)
                }
            }
        }
        .padding(.vertical, 12)
    }

    // MARK: - Status Overview Section
    private func statusOverviewSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("當前狀態")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.Text.header(colorScheme))
                Spacer()
            }

            HStack(spacing: 16) {
                // Vacation Status
                statusCard(
                    title: "排休狀態",
                    value: isVacationPublished ? "已開放" : "未開放",
                    color: isVacationPublished ? .green : .orange,
                    icon: isVacationPublished ? "checkmark.circle.fill" : "clock.fill"
                )

                // Employee Count
                statusCard(
                    title: "員工申請",
                    value: "\(employeeVacationCount)人",
                    color: .blue,
                    icon: "person.3.fill"
                )
            }
        }
    }

    private func statusCard(title: String, value: String, color: Color, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(color)

            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.Background.primary(colorScheme))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }

    // MARK: - Quick Actions Section
    private func quickActionsSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("快速操作")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.Text.header(colorScheme))
                Spacer()
            }

            VStack(spacing: 12) {
                if !isVacationPublished {
                    quickActionButton(
                        action: .publishVacation,
                        title: "發佈排休",
                        subtitle: "設定並開放員工進行排休申請",
                        isPrimary: true
                    )
                } else {
                    quickActionButton(
                        action: .unpublishVacation,
                        title: "取消發佈",
                        subtitle: "關閉排休申請功能",
                        isPrimary: false
                    )
                }

                if isVacationPublished && employeeVacationCount > 0 {
                    quickActionButton(
                        action: .generateSchedule,
                        title: "生成班表",
                        subtitle: "根據員工排休生成工作班表",
                        isPrimary: true
                    )
                }
            }
        }
    }

    private func quickActionButton(action: BossAction, title: String, subtitle: String, isPrimary: Bool) -> some View {
        Button(action: {
            selectedAction = action
        }) {
            HStack(spacing: 16) {
                Image(systemName: action.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isPrimary ? .white : action.color)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(isPrimary ? action.color : action.color.opacity(0.1))
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isPrimary ? .white : AppColors.Text.header(colorScheme))

                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(isPrimary ? .white.opacity(0.8) : AppColors.Text.header(colorScheme).opacity(0.7))
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isPrimary ? .white.opacity(0.7) : AppColors.Text.header(colorScheme).opacity(0.5))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isPrimary ? action.color : AppColors.Background.primary(colorScheme))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isPrimary ? Color.clear : AppColors.Text.header(colorScheme).opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isLoading)
        .opacity(isLoading ? 0.6 : 1.0)
    }

    // MARK: - Management Options Section
    private func managementOptionsSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("管理選項")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.Text.header(colorScheme))
                Spacer()
            }

            VStack(spacing: 8) {
                managementOptionRow(
                    action: .manageVacationLimits,
                    title: "排休設定",
                    subtitle: "設定排休規則和限制"
                )

                Divider()
                    .background(AppColors.Text.header(colorScheme).opacity(0.1))

                managementOptionRow(
                    action: .viewSchedule,
                    title: "查看班表",
                    subtitle: "查看當前工作班表"
                )

                Divider()
                    .background(AppColors.Text.header(colorScheme).opacity(0.1))

                managementOptionRow(
                    action: .employeeManagement,
                    title: "員工管理",
                    subtitle: "管理員工資訊"
                )
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.Background.primary(colorScheme))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppColors.Text.header(colorScheme).opacity(0.1), lineWidth: 1)
                    )
            )
        }
    }

    private func managementOptionRow(action: BossAction, title: String, subtitle: String) -> some View {
        Button(action: {
            selectedAction = action
        }) {
            HStack(spacing: 12) {
                Image(systemName: action.icon)
                    .font(.system(size: 16))
                    .foregroundColor(action.color)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.Text.header(colorScheme))

                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.6))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.4))
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isLoading)
        .opacity(isLoading ? 0.6 : 1.0)
    }
}

#Preview {
    BossManagementSheet(
        isPresented: .constant(true),
        selectedAction: .constant(nil),
        isVacationPublished: .constant(false),
        employeeVacationCount: .constant(3),
        isLoading: .constant(false)
    )
    .environmentObject(ThemeManager())
}
