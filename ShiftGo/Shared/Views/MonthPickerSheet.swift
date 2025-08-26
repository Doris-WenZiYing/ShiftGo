//
//  MonthPickerSheet.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/8/25.
//

import SwiftUI

struct MonthPickerSheet: View {
    @Binding var selectedYear: Int
    @Binding var selectedMonth: Int
    @Binding var isPresented: Bool
    let controller: CalendarController

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemBackground),
                        Color(.systemGray6).opacity(0.3)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            VStack(spacing: 12) {
                                HStack {
                                    Image(systemName: "calendar")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.blue)
                                    Text("Year")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.primary)
                                }
                                .padding(.top, 16)

                                Picker("Year", selection: $selectedYear) {
                                    ForEach(1900...2100, id: \.self) { year in
                                        Text(String(year))
                                            .font(.system(size: 22, weight: .medium))
                                            .tag(year)
                                    }
                                }
                                .pickerStyle(WheelPickerStyle())
                                .frame(height: 200)
                                .clipped()
                            }
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                            )
                            .padding(.leading, 20)
                            .padding(.trailing, 8)

                            VStack(spacing: 12) {
                                HStack {
                                    Image(systemName: "calendar.circle")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.green)
                                    Text("Month")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.primary)
                                }
                                .padding(.top, 16)

                                Picker("Month", selection: $selectedMonth) {
                                    ForEach(1...12, id: \.self) { month in
                                        Text("\(month)")
                                            .font(.system(size: 22, weight: .medium))
                                            .tag(month)
                                    }
                                }
                                .pickerStyle(WheelPickerStyle())
                                .frame(height: 200)
                                .clipped()
                            }
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                            )
                            .padding(.trailing, 20)
                            .padding(.leading, 8)
                        }
                        .padding(.bottom, 20)
                    }

                    VStack(spacing: 12) {
                        Text("Fast Select")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)

                        HStack(spacing: 12) {
                            quickSelectButton(title: "Last Month", action: {
                                let calendar = Calendar.current
                                let lastMonth = calendar.date(byAdding: .month, value: -1, to: Date()) ?? Date()
                                selectedYear = calendar.component(.year, from: lastMonth)
                                selectedMonth = calendar.component(.month, from: lastMonth)
                            })

                            quickSelectButton(title: "This Month", action: {
                                let now = Date()
                                selectedYear = Calendar.current.component(.year, from: now)
                                selectedMonth = Calendar.current.component(.month, from: now)
                            })

                            quickSelectButton(title: "Next Month", action: {
                                let calendar = Calendar.current
                                let nextMonth = calendar.date(byAdding: .month, value: 1, to: Date()) ?? Date()
                                selectedYear = calendar.component(.year, from: nextMonth)
                                selectedMonth = calendar.component(.month, from: nextMonth)
                            })
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)

                    Spacer()
                }
            }
            .navigationTitle("Choose Date")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isPresented = false
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 16))
                            Text("Cancel")
                                .font(.system(size: 16))
                        }
                        .foregroundColor(.secondary)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        controller.navigateToMonth(year: selectedYear, month: selectedMonth)
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isPresented = false
                        }
                    }) {
                        HStack(spacing: 6) {
                            Text("Go")
                                .font(.system(size: 16, weight: .semibold))
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 16))
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
        }
        .presentationDetents([.fraction(0.55)])
        .presentationDragIndicator(.visible)
    }

    private func quickSelectButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.blue)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.blue.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MonthPickerSheet(selectedYear: .constant(2025), selectedMonth: .constant(2025), isPresented: .constant(true), controller: CalendarController())
}

