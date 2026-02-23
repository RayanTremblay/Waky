import UIKit
import ManagedSettingsUI
import FamilyControls
import ManagedSettings

/// Custom shield shown when the user opens a blocked app (e.g. TikTok, Instagram).
/// Shows "Waky has blocked this app", a sleep-themed quote, and a message about the sleep commitment.
final class WakyShieldConfigurationDataSource: ShieldConfigurationDataSource {

    private static let quotes = [
        "Rest is not idle. It's the invisible repair your body needs.",
        "Your future self will thank you for sleeping tonight.",
        "Sleep is the best meditation.",
        "A good night's sleep is the best kind of reset.",
        "Protect your sleep—it protects everything else.",
        "The bridge between despair and hope is a good night's sleep.",
    ]

    private static let commitmentMessage = "To respect your sleep commitment, you can't use this app right now."

    /// Transparent 1x1 image so the system does not show the default blue hourglass.
    private static var noIcon: UIImage {
        let size = CGSize(width: 1, height: 1)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in }
    }

    private static var randomQuote: String {
        quotes.randomElement() ?? quotes[0]
    }

    private static func appShieldConfiguration(title: String) -> ShieldConfiguration {
        let quote = randomQuote
        let subtitleText = "\(quote)\n\n\(commitmentMessage)"
        return ShieldConfiguration(
            icon: noIcon,
            title: ShieldConfiguration.Label(
                text: title,
                color: .label
            ),
            subtitle: ShieldConfiguration.Label(
                text: subtitleText,
                color: .secondaryLabel
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "OK",
                color: .white
            ),
            primaryButtonBackgroundColor: UIColor(red: 0.88, green: 0.49, blue: 0.30, alpha: 1.0) // Waky accent
        )
    }

    override func configuration(shielding application: Application) -> ShieldConfiguration {
        Self.appShieldConfiguration(title: "Waky has blocked this app")
    }

    /// Apps blocked by category (e.g. Social Networking) use this; without it the system shows the default shield.
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        Self.appShieldConfiguration(title: "Waky has blocked this app")
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        ShieldConfiguration(
            icon: Self.noIcon,
            title: ShieldConfiguration.Label(text: "Waky has blocked this website", color: .label),
            subtitle: ShieldConfiguration.Label(text: Self.commitmentMessage, color: .secondaryLabel),
            primaryButtonLabel: ShieldConfiguration.Label(text: "OK", color: .white),
            primaryButtonBackgroundColor: UIColor(red: 0.88, green: 0.49, blue: 0.30, alpha: 1.0)
        )
    }

    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        ShieldConfiguration(
            icon: Self.noIcon,
            title: ShieldConfiguration.Label(text: "Waky has blocked this website", color: .label),
            subtitle: ShieldConfiguration.Label(text: Self.commitmentMessage, color: .secondaryLabel),
            primaryButtonLabel: ShieldConfiguration.Label(text: "OK", color: .white),
            primaryButtonBackgroundColor: UIColor(red: 0.88, green: 0.49, blue: 0.30, alpha: 1.0)
        )
    }
}
