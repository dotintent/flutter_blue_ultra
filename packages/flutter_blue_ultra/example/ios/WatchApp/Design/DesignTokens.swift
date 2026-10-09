import SwiftUI

extension Color {
    /// 0xRRGGBB
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }
}

/// Single source of truth for colours, type and spacing. Dark only.
/// Mirrors the Wear OS app's DesignTokens.kt; New York (serif) stands in for Crimson Pro,
/// SF for Inter and SF Mono for JetBrains Mono.
enum DesignTokens {
    enum Colors {
        static let accent = Color(hex: 0xFF3B5C)
        static let background = Color(hex: 0x0A0A0A)
        static let surface = Color(hex: 0x141414)
        static let surfaceAlt = Color(hex: 0x1C1C1C)
        static let surfaceHigh = Color(hex: 0x262626)
        static let text = Color(hex: 0xFFFFFF)
        static let textDim = Color(hex: 0x9A9A9A)
        static let textFaint = Color(hex: 0x5A5A5A)
        static let success = Color(hex: 0x7CE0A8)
        static let warn = Color(hex: 0xF5C66F)
    }

    enum Fonts {
        static let titleLarge = Font.system(size: 18, weight: .semibold, design: .serif)
        static let titleSmall = Font.system(size: 15, weight: .semibold, design: .serif)
        static let bodyLarge = Font.system(size: 14, design: .default)
        static let bodySmall = Font.system(size: 12, design: .default)
        static let button = Font.system(size: 14, weight: .medium, design: .default)
        static let caption = Font.system(size: 11, design: .default)
        static let monoSmall = Font.system(size: 10, design: .monospaced)
    }

    enum Dimens {
        static let dot: CGFloat = 8
        static let iconSmall: CGFloat = 16
        static let iconLarge: CGFloat = 32
        static let chipRadius: CGFloat = 6
        static let cardRadius: CGFloat = 12
        static let gap: CGFloat = 4
    }
}
