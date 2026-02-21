import SwiftUI

// MARK: - Waky design system (from UI inspiration)
// Warm cream/beige background, orange accents, dark blue-grey text, rounded cards

enum WakyTheme {
    // Backgrounds
    static let background = Color(red: 0.96, green: 0.94, blue: 0.91)   // warm cream
    static let cardBackground = Color(red: 0.98, green: 0.96, blue: 0.94)
    static let cardBackgroundSelected = Color(red: 0.99, green: 0.97, blue: 0.95)
    
    // Accent (orange from inspo)
    static let accent = Color(red: 0.88, green: 0.49, blue: 0.30)
    static let accentLight = Color(red: 0.95, green: 0.75, blue: 0.65)
    
    // Text
    static let textPrimary = Color(red: 0.22, green: 0.25, blue: 0.32)
    static let textSecondary = Color(red: 0.45, green: 0.48, blue: 0.55)
    
    // Layout
    static let cornerRadius: CGFloat = 16
    static let cornerRadiusLarge: CGFloat = 24
    static let cardPadding: CGFloat = 20
}
