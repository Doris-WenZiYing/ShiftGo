//
//  DesignSystem.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/9/17.
//

import SwiftUI

// MARK: - Design Tokens
struct DesignTokens {

    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let xxxl: CGFloat = 32
    }

    // MARK: - Corner Radius
    struct CornerRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let card: CGFloat = 16
        static let button: CGFloat = 12
    }

    // MARK: - Typography
    struct Typography {
        static let largeTitle = Font.system(size: 28, weight: .bold)
        static let title = Font.system(size: 22, weight: .semibold)
        static let headline = Font.system(size: 18, weight: .semibold)
        static let body = Font.system(size: 16, weight: .regular)
        static let bodyMedium = Font.system(size: 16, weight: .medium)
        static let caption = Font.system(size: 14, weight: .regular)
        static let captionMedium = Font.system(size: 14, weight: .medium)
        static let small = Font.system(size: 12, weight: .regular)
        static let smallMedium = Font.system(size: 12, weight: .medium)
    }

    // MARK: - Shadows
    struct Shadow {
        static let light = Color.black.opacity(0.05)
        static let medium = Color.black.opacity(0.1)
        static let heavy = Color.black.opacity(0.2)
    }
}

// MARK: - Reusable UI Components

// MARK: - Primary Card
struct PrimaryCard<Content: View>: View {
    let content: Content
    let backgroundColor: Color?

    init(backgroundColor: Color? = nil, @ViewBuilder content: () -> Content) {
        self.backgroundColor = backgroundColor
        self.content = content()
    }

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.card)
                    .fill(backgroundColor ?? AppColors.Background.secondary(colorScheme))
                    .shadow(color: DesignTokens.Shadow.light, radius: 2, x: 0, y: 1)
            )
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    let subtitle: String?
    let action: (() -> Void)?
    let actionTitle: String?

    init(_ title: String, subtitle: String? = nil, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.actionTitle = actionTitle
        self.action = action
    }

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            HStack {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(title)
                        .font(DesignTokens.Typography.headline)
                        .foregroundColor(AppColors.Text.header(colorScheme))

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(DesignTokens.Typography.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                if let action = action, let actionTitle = actionTitle {
                    Button(actionTitle, action: action)
                        .font(DesignTokens.Typography.captionMedium)
                        .foregroundColor(AppColors.Theme.primary)
                }
            }
        }
    }
}

// MARK: - Stats Card
struct StatsCard: View {
    let title: String
    let value: String
    let subtitle: String?
    let icon: String
    let color: Color?

    init(title: String, value: String, subtitle: String? = nil, icon: String, color: Color? = nil) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.icon = icon
        self.color = color ?? AppColors.Theme.primary
    }

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        PrimaryCard {
            VStack(spacing: DesignTokens.Spacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)

                VStack(spacing: DesignTokens.Spacing.xs) {
                    Text(value)
                        .font(DesignTokens.Typography.title)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.Text.header(colorScheme))

                    Text(title)
                        .font(DesignTokens.Typography.captionMedium)
                        .foregroundColor(AppColors.Text.header(colorScheme))

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(DesignTokens.Typography.small)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(DesignTokens.Spacing.lg)
        }
    }
}

// MARK: - Primary Button
struct PrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    let isDisabled: Bool
    let isLoading: Bool
    let style: ButtonStyle

    enum ButtonStyle {
        case primary, secondary, destructive

        func backgroundColor(colorScheme: ColorScheme) -> Color {
            switch self {
            case .primary: return AppColors.Theme.primary
            case .secondary: return AppColors.Background.secondary(colorScheme)
            case .destructive: return .red
            }
        }

        func foregroundColor(colorScheme: ColorScheme) -> Color {
            switch self {
            case .primary, .destructive: return .white
            case .secondary: return AppColors.Text.header(colorScheme)
            }
        }
    }

    init(_ title: String, icon: String? = nil, style: ButtonStyle = .primary,
         isDisabled: Bool = false, isLoading: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.style = style
        self.isDisabled = isDisabled
        self.isLoading = isLoading
        self.action = action
    }

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignTokens.Spacing.sm) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: style.foregroundColor(colorScheme: colorScheme)))
                        .scaleEffect(0.8)
                } else if let icon = icon {
                    Image(systemName: icon)
                        .font(DesignTokens.Typography.bodyMedium)
                }

                Text(title)
                    .font(DesignTokens.Typography.bodyMedium)
            }
            .foregroundColor(style.foregroundColor(colorScheme: colorScheme))
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignTokens.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.button)
                    .fill(style.backgroundColor(colorScheme: colorScheme).opacity(isDisabled ? 0.5 : 1.0))
            )
        }
        .disabled(isDisabled || isLoading)
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String?
    let iconColor: Color
    let action: (() -> Void)?

    init(icon: String, title: String, subtitle: String? = nil,
         iconColor: Color = AppColors.Theme.primary, action: (() -> Void)? = nil) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.iconColor = iconColor
        self.action = action
    }

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: action ?? {}) {
            HStack(spacing: DesignTokens.Spacing.md) {
                // Icon container
                Circle()
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 20))
                            .foregroundColor(iconColor)
                    )

                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(title)
                        .font(DesignTokens.Typography.bodyMedium)
                        .foregroundColor(AppColors.Text.header(colorScheme))

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(DesignTokens.Typography.small)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                if action != nil {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            .padding(DesignTokens.Spacing.lg)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(action == nil)
    }
}

// MARK: - Progress Ring
struct ProgressRing: View {
    let progress: Double
    let color: Color
    let lineWidth: CGFloat

    init(progress: Double, color: Color = AppColors.Theme.primary, lineWidth: CGFloat = 8) {
        self.progress = progress
        self.color = color
        self.lineWidth = lineWidth
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1), value: progress)
        }
    }
}

// MARK: - Alert Card
struct AlertCard: View {
    let title: String
    let message: String
    let type: AlertType
    let action: (() -> Void)?
    let actionTitle: String?

    enum AlertType {
        case info, warning, success, error

        var color: Color {
            switch self {
            case .info: return AppColors.Theme.primary
            case .warning: return .orange
            case .success: return .green
            case .error: return .red
            }
        }

        var icon: String {
            switch self {
            case .info: return "info.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .success: return "checkmark.circle.fill"
            case .error: return "xmark.circle.fill"
            }
        }
    }

    init(title: String, message: String, type: AlertType, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        self.title = title
        self.message = message
        self.type = type
        self.actionTitle = actionTitle
        self.action = action
    }

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        PrimaryCard(backgroundColor: type.color.opacity(0.05)) {
            HStack(spacing: DesignTokens.Spacing.md) {
                Image(systemName: type.icon)
                    .font(.system(size: 20))
                    .foregroundColor(type.color)

                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(title)
                        .font(DesignTokens.Typography.captionMedium)
                        .foregroundColor(AppColors.Text.header(colorScheme))

                    Text(message)
                        .font(DesignTokens.Typography.small)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if let action = action, let actionTitle = actionTitle {
                    Button(actionTitle, action: action)
                        .font(DesignTokens.Typography.smallMedium)
                        .foregroundColor(type.color)
                }
            }
            .padding(DesignTokens.Spacing.lg)
        }
    }
}

// MARK: - Extensions
extension View {
    func designSystemCard() -> some View {
        self.modifier(CardModifier())
    }
}

struct CardModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.card)
                    .fill(AppColors.Background.secondary(colorScheme))
                    .shadow(color: DesignTokens.Shadow.light, radius: 2, x: 0, y: 1)
            )
    }
}
