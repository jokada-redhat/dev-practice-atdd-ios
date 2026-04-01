import SwiftUI

enum AppTheme {
    // MARK: - Primary Colors
    static let primary = Color(hex: 0x002C98)
    static let primaryContainer = Color(hex: 0x1A43BF)
    static let onPrimary = Color.white
    static let onPrimaryContainer = Color(hex: 0xB2BFFF)

    // MARK: - Secondary Colors
    static let secondary = Color(hex: 0x515E7C)
    static let secondaryContainer = Color(hex: 0xCDDAFD)
    static let secondaryFixed = Color(hex: 0xD8E2FF)

    // MARK: - Tertiary Colors
    static let tertiary = Color(hex: 0x6C1E00)
    static let tertiaryContainer = Color(hex: 0x932C00)

    // MARK: - Surface Colors
    static let background = Color(hex: 0xF8F9FC)
    static let surface = Color(hex: 0xF8F9FC)
    static let surfaceContainer = Color(hex: 0xEDEEF1)
    static let surfaceContainerHigh = Color(hex: 0xE7E8EB)
    static let surfaceContainerHighest = Color(hex: 0xE1E2E5)
    static let surfaceContainerLow = Color(hex: 0xF2F3F6)
    static let surfaceContainerLowest = Color.white

    // MARK: - Text Colors
    static let onBackground = Color(hex: 0x191C1E)
    static let onSurface = Color(hex: 0x191C1E)
    static let onSurfaceVariant = Color(hex: 0x444654)
    static let outline = Color(hex: 0x747685)
    static let outlineVariant = Color(hex: 0xC4C5D6)

    // MARK: - Status Colors
    static let error = Color(hex: 0xBA1A1A)
    static let primaryFixed = Color(hex: 0xDDE1FF)

    // MARK: - Gradients
    static let primaryGradient = LinearGradient(
        colors: [primary, primaryContainer],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Color Hex Extension

extension Color {
    init(hex: UInt, opacity: Double = 1.0) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: opacity
        )
    }
}

// MARK: - Reusable View Modifiers

struct StitchCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(AppTheme.surfaceContainerLowest)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct StitchInputStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(12)
            .background(AppTheme.surfaceContainerHighest)
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

struct StitchPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(AppTheme.primaryGradient)
            .clipShape(Capsule())
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

struct StatusBadge: View {
    let text: String
    let isAvailable: Bool

    var body: some View {
        Text(text)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(isAvailable ? AppTheme.primaryFixed : AppTheme.tertiaryContainer.opacity(0.15))
            .foregroundStyle(isAvailable ? AppTheme.primary : AppTheme.tertiary)
            .clipShape(Capsule())
    }
}

extension View {
    func stitchCard() -> some View {
        modifier(StitchCardStyle())
    }

    func stitchInput() -> some View {
        modifier(StitchInputStyle())
    }
}
