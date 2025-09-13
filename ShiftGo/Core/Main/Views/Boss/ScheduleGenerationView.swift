//
//  ScheduleGenerationView.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/9/13.
//

import SwiftUI

struct ScheduleGenerationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var viewModel = BossMainViewModel()
    @StateObject private var scheduleGenerator = ScheduleGenerator()

    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var generatedSchedule: WorkSchedule?
    @State private var showingSchedulePreview = false
    @State private var showingExportOptions = false

    private let months = [
        1: "1月", 2: "2月", 3: "3月", 4: "4月",
        5: "5月", 6: "6月", 7: "7月", 8: "8月",
        9: "9月", 10: "10月", 11: "11月", 12: "12月"
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection()
                    monthSelectionSection()
                    requirementsSection()
                    generateButtonSection()

                    if let schedule = generatedSchedule {
                        scheduleResultSection(schedule)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
            }
            .background(AppColors.Background.primary(colorScheme))
            .navigationTitle("生成班表")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("關閉") { dismiss() }
                        .foregroundColor(AppColors.Text.header(colorScheme))
                }
            }
        }
        .sheet(isPresented: $showingSchedulePreview) {
            if let schedule = generatedSchedule {
//                SchedulePreviewView(schedule: schedule)
            }
        }
        .sheet(isPresented: $showingExportOptions) {
            if let schedule = generatedSchedule {
//                ScheduleExportView(schedule: schedule)
            }
        }
        .onAppear {
            viewModel.loadData(for: selectedYear, month: selectedMonth)
        }
    }

    // MARK: - Header Section
    private func headerSection() -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 32))
                    .foregroundColor(.orange)

                VStack(alignment: .leading, spacing: 4) {
                    Text("智慧班表生成")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppColors.Text.header(colorScheme))

                    Text("根據員工排休自動生成工作班表")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.7))
                }

                Spacer()

                if scheduleGenerator.isGenerating {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                        .scaleEffect(0.8)
                }
            }
        }
        .padding(.vertical, 12)
    }

    // MARK: - Month Selection Section
    private func monthSelectionSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("選擇生成月份")

            VStack(spacing: 16) {
                // Year Selector
                HStack {
                    Text("年份")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppColors.Text.header(colorScheme))

                    Spacer()

                    Picker("選擇年份", selection: $selectedYear) {
                        ForEach(2024...2026, id: \.self) { year in
                            Text("\(year)年").tag(year)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .accentColor(.orange)
                }
                .padding(16)
                .background(settingCardBackground())

                // Month Selector
                HStack {
                    Text("月份")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppColors.Text.header(colorScheme))

                    Spacer()

                    Picker("選擇月份", selection: $selectedMonth) {
                        ForEach(1...12, id: \.self) { month in
                            Text(months[month] ?? "").tag(month)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .accentColor(.orange)
                }
                .padding(16)
                .background(settingCardBackground())
            }
        }
        .onChange(of: selectedYear) { _, _ in
            loadDataForSelectedMonth()
        }
        .onChange(of: selectedMonth) { _, _ in
            loadDataForSelectedMonth()
        }
    }

    // MARK: - Requirements Section
    private func requirementsSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("班表生成條件")

            VStack(spacing: 12) {
                requirementItem(
                    icon: "person.3.fill",
                    title: "員工排休",
                    status: viewModel.employeeVacationCount > 0 ? "已收集" : "無資料",
                    isValid: true,
                    detail: "\(viewModel.employeeVacationCount) 人已申請"
                )

                requirementItem(
                    icon: "checkmark.circle.fill",
                    title: "排休審核",
                    status: hasApprovedVacations() ? "已完成" : "待審核",
                    isValid: hasApprovedVacations(),
                    detail: getApprovalSummary()
                )

                requirementItem(
                    icon: "calendar.badge.checkmark",
                    title: "可生成班表",
                    status: canGenerateSchedule() ? "就緒" : "請先完成上述條件",
                    isValid: canGenerateSchedule(),
                    detail: canGenerateSchedule() ? "所有條件已滿足" : ""
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

    private func requirementItem(
        icon: String,
        title: String,
        status: String,
        isValid: Bool,
        detail: String
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(isValid ? .green : .orange)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.Text.header(colorScheme))

                    Spacer()

                    Text(status)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(isValid ? .green : .orange)
                }

                if !detail.isEmpty {
                    Text(detail)
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.Text.header(colorScheme).opacity(0.6))
                }
            }
        }
    }

    // MARK: - Generate Button Section
    private func generateButtonSection() -> some View {
        VStack(spacing: 16) {
            Button(action: generateSchedule) {
                HStack(spacing: 8) {
                    if scheduleGenerator.isGenerating {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "wand.and.stars")
                    }

                    Text(scheduleGenerator.isGenerating ? "生成中..." : "生成班表")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(canGenerateSchedule() ? Color.orange : Color.gray)
                .cornerRadius(12)
            }
            .disabled(!canGenerateSchedule() || scheduleGenerator.isGenerating)

            if !canGenerateSchedule() {
                Text("請先完成員工排休審核")
                    .font(.system(size: 14))
                    .foregroundColor(.orange)
            }
        }
    }

    // MARK: - Schedule Result Section
    private func scheduleResultSection(_ schedule: WorkSchedule) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("生成結果")

            VStack(spacing: 16) {
                // 統計卡片
                HStack(spacing: 12) {
                    statCard("工作天數", "\(schedule.totalWorkDays)", .green)
                    statCard("總工時", "\(Int(getTotalHours(schedule)))", .blue)
                    statCard("參與人數", "\(getUniqueEmployeeCount(schedule))", .purple)
                }

                // 操作按鈕
                VStack(spacing: 12) {
                    Button("預覽班表") {
                        showingSchedulePreview = true
                    }
                    .buttonStyle(ActionButtonStyle(color: .blue))

                    Button("匯出班表") {
                        showingExportOptions = true
                    }
                    .buttonStyle(ActionButtonStyle(color: .green))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.green.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.green.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }

    private func statCard(_ title: String, _ value: String, _ color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(color)

            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }

    // MARK: - Helper Methods

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(AppColors.Text.header(colorScheme))
    }

    private func settingCardBackground() -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(AppColors.Background.primary(colorScheme))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppColors.Text.header(colorScheme).opacity(0.1), lineWidth: 1)
            )
    }

    private func loadDataForSelectedMonth() {
        viewModel.loadData(for: selectedYear, month: selectedMonth)
    }

    private func hasApprovedVacations() -> Bool {
        return viewModel.employeeVacations.contains { $0.status == .approved }
    }

    private func getApprovalSummary() -> String {
        let approved = viewModel.employeeVacations.filter { $0.status == .approved }.count
        let pending = viewModel.employeeVacations.filter { $0.status == .pending }.count
        return "已核准 \(approved) 筆，待審核 \(pending) 筆"
    }

    private func canGenerateSchedule() -> Bool {
        return viewModel.employeeVacationCount > 0
    }

    private func generateSchedule() {
        scheduleGenerator.isGenerating = true

        // 模擬員工資料（實際應該從 Firebase 獲取）
        let mockEmployees = [
            User(id: "1", email: "emp1@test.com", name: "王小明", role: "employee", employeeId: "EMP001"),
            User(id: "2", email: "emp2@test.com", name: "李美麗", role: "employee", employeeId: "EMP002"),
            User(id: "3", email: "emp3@test.com", name: "陳大華", role: "employee", employeeId: "EMP003")
        ]

        DispatchQueue.global().async {
            let schedule = scheduleGenerator.generateSchedule(
                year: selectedYear,
                month: selectedMonth,
                employees: mockEmployees,
                vacations: viewModel.employeeVacations
            )

            DispatchQueue.main.async {
                scheduleGenerator.isGenerating = false
                generatedSchedule = schedule

                // 發送通知
                NotificationManager.shared.notifySchedulePublished(
                    monthYear: "\(selectedYear)年\(selectedMonth)月"
                )
            }
        }
    }

    private func getTotalHours(_ schedule: WorkSchedule) -> Double {
        return schedule.shifts.reduce(0) { $0 + $1.totalHours }
    }

    private func getUniqueEmployeeCount(_ schedule: WorkSchedule) -> Int {
        let allEmployees = schedule.shifts.flatMap { $0.assignments.map { $0.employeeId } }
        return Set(allEmployees).count
    }
}

// MARK: - Action Button Style
struct ActionButtonStyle: ButtonStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(color)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

#Preview {
    ScheduleGenerationView()
}
