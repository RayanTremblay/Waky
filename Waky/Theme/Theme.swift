import SwiftUI

// MARK: - Waky design system (from UI inspiration)
// Light: warm cream/beige background, orange accents. Dark: adaptive colors from Assets.
// All colors use asset catalog so they switch with the app’s preferredColorScheme (dark mode).

enum WakyTheme {
    // Backgrounds (adaptive: light = cream, dark = dark gray)
    static let background = Color("WakyBackground")
    static let cardBackground = Color("WakyCardBackground")
    static let cardBackgroundSelected = Color("WakyCardBackgroundSelected")

    // Accent (adaptive orange)
    static let accent = Color("WakyAccent")
    static let accentLight = Color("WakyAccentLight")

    // Text (adaptive)
    static let textPrimary = Color("WakyTextPrimary")
    static let textSecondary = Color("WakyTextSecondary")

    // Layout
    static let cornerRadius: CGFloat = 16
    static let cornerRadiusLarge: CGFloat = 24
    static let cardPadding: CGFloat = 20
}
