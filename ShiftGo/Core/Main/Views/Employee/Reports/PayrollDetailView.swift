//
//  PayrollDetailView.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/9/13.
//

import SwiftUI

struct PayrollDetailView: View {
    let timeRange: EmployeeReportsView.TimeRange
    let payrollData: PayrollReport
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection()
                    salaryBreakdownSection()
                    deductionsSection()
                    payslipSection()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
            }
            .background(AppColors.Background.primary(colorScheme))
            .navigationTitle("薪資明細")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("關閉") { dismiss() }
                        .foregroundColor(AppColors.Text.header(colorScheme))
                }
            }
        }
    }

    // MARK: - Header Section
    private func headerSection() -> some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.fill")
                .font(.system(size: 40))
                .foregroundColor(.green)

            VStack(spacing: 8) {
                Text("\(timeRange.rawValue)薪資明細")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppColors.Text.header(colorScheme))

                Text("詳細收入與扣除項目")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.7))
            }

            // 總收入顯示
            VStack(spacing: 4) {
                Text("實領薪資")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)

                Text("NT$ \(payrollData.netPay.formatted())")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.green)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.green.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.green.opacity(0.3), lineWidth: 2)
                    )
            )
        }
        .padding(.top, 20)
    }

    // MARK: - Salary Breakdown Section
    private func salaryBreakdownSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("💰 收入明細")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppColors.Text.header(colorScheme))

            VStack(spacing: 12) {
                payrollRow(
                    title: "基本薪資",
                    amount: payrollData.basePay,
                    icon: "dollarsign.circle.fill",
                    color: .blue,
                    isPositive: true
                )

                payrollRow(
                    title: "加班費",
                    amount: payrollData.overtimePay,
                    icon: "clock.badge.fill",
                    color: .orange,
                    isPositive: true
                )

                payrollRow(
                    title: "津貼補助",
                    amount: payrollData.allowance,
                    icon: "gift.fill",
                    color: .purple,
                    isPositive: true
                )

                Divider()
                    .background(AppColors.Text.header(colorScheme).opacity(0.3))

                payrollRow(
                    title: "總收入",
                    amount: payrollData.totalEarnings,
                    icon: "plus.circle.fill",
                    color: .green,
                    isPositive: true,
                    isBold: true
                )
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.Background.secondary(colorScheme))
            )
        }
    }

    // MARK: - Deductions Section
    private func deductionsSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📋 扣除項目")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppColors.Text.header(colorScheme))

            VStack(spacing: 12) {
                payrollRow(
                    title: "勞保費",
                    amount: calculateLaborInsurance(),
                    icon: "shield.fill",
                    color: .blue,
                    isPositive: false
                )

                payrollRow(
                    title: "健保費",
                    amount: calculateHealthInsurance(),
                    icon: "heart.fill",
                    color: .red,
                    isPositive: false
                )

                payrollRow(
                    title: "所得稅",
                    amount: calculateIncomeTax(),
                    icon: "doc.text.fill",
                    color: .orange,
                    isPositive: false
                )

                Divider()
                    .background(AppColors.Text.header(colorScheme).opacity(0.3))

                payrollRow(
                    title: "總扣除",
                    amount: payrollData.deductions,
                    icon: "minus.circle.fill",
                    color: .red,
                    isPositive: false,
                    isBold: true
                )
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.Background.secondary(colorScheme))
            )
        }
    }

    // MARK: - Payslip Section
    private func payslipSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📄 薪資單摘要")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppColors.Text.header(colorScheme))

            VStack(spacing: 16) {
                // 薪資計算公式
                VStack(spacing: 8) {
                    HStack {
                        Text("總收入")
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.Text.header(colorScheme))
                        Spacer()
                        Text("NT$ \(payrollData.totalEarnings)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.green)
                    }

                    HStack {
                        Text("總扣除")
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.Text.header(colorScheme))
                        Spacer()
                        Text("- NT$ \(payrollData.deductions)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.red)
                    }

                    Rectangle()
                        .fill(AppColors.Text.header(colorScheme).opacity(0.3))
                        .frame(height: 1)

                    HStack {
                        Text("實領薪資")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(AppColors.Text.header(colorScheme))
                        Spacer()
                        Text("NT$ \(payrollData.netPay)")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.green)
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.green.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.green.opacity(0.2), lineWidth: 1)
                        )
                )

                // 導出按鈕
                Button(action: exportPayslip) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                        Text("導出薪資單")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .cornerRadius(12)
                }

                // 說明文字
                Text("💡 此薪資明細僅供參考，正式薪資單以公司人事部門提供為準。")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - Helper Views
    private func payrollRow(
        title: String,
        amount: Int,
        icon: String,
        color: Color,
        isPositive: Bool,
        isBold: Bool = false
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 24)

            Text(title)
                .font(.system(size: isBold ? 16 : 14, weight: isBold ? .semibold : .medium))
                .foregroundColor(AppColors.Text.header(colorScheme))

            Spacer()

            Text("\(isPositive ? "" : "- ")NT$ \(amount)")
                .font(.system(size: isBold ? 16 : 14, weight: isBold ? .bold : .medium))
                .foregroundColor(isPositive ? color : .red)
        }
        .padding(.vertical, isBold ? 8 : 4)
    }

    // MARK: - Helper Methods
    private func calculateLaborInsurance() -> Int {
        // 簡化計算：總收入的 1.5%
        return Int(Double(payrollData.totalEarnings) * 0.015)
    }

    private func calculateHealthInsurance() -> Int {
        // 簡化計算：總收入的 1.2%
        return Int(Double(payrollData.totalEarnings) * 0.012)
    }

    private func calculateIncomeTax() -> Int {
        // 簡化計算：剩餘扣除金額
        let laborInsurance = calculateLaborInsurance()
        let healthInsurance = calculateHealthInsurance()
        return payrollData.deductions - laborInsurance - healthInsurance
    }

    private func exportPayslip() {
        // 實現導出薪資單功能
        print("導出薪資單")

        // 可以實現 PDF 生成或分享功能
        let payslipText = generatePayslipText()

        // 使用系統分享功能
        let activityVC = UIActivityViewController(
            activityItems: [payslipText],
            applicationActivities: nil
        )

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }

    private func generatePayslipText() -> String {
        var text = "📄 \(timeRange.rawValue)薪資明細\n"
        text += "===================\n\n"
        text += "💰 收入項目：\n"
        text += "基本薪資：NT$ \(payrollData.basePay)\n"
        text += "加班費：NT$ \(payrollData.overtimePay)\n"
        text += "津貼補助：NT$ \(payrollData.allowance)\n"
        text += "小計：NT$ \(payrollData.totalEarnings)\n\n"
        text += "📋 扣除項目：\n"
        text += "勞保費：NT$ \(calculateLaborInsurance())\n"
        text += "健保費：NT$ \(calculateHealthInsurance())\n"
        text += "所得稅：NT$ \(calculateIncomeTax())\n"
        text += "小計：NT$ \(payrollData.deductions)\n\n"
        text += "✅ 實領薪資：NT$ \(payrollData.netPay)\n"
        text += "===================\n"
        text += "產生時間：\(Date().formatted(date: .abbreviated, time: .shortened))"

        return text
    }
}

#Preview {
    PayrollDetailView(
        timeRange: .thisMonth,
        payrollData: PayrollReport(
            totalEarnings: 42000,
            basePay: 33600,
            overtimePay: 3200,
            allowance: 5200,
            deductions: 2000
        )
    )
}

#Preview {
//    PayrollDetailView(timeRange: <#EmployeeReportsView.TimeRange#>, payrollData: )
}
