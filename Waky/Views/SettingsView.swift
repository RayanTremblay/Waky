import SwiftUI
import Inject

/// Settings tab: dark mode toggle, privacy policy, terms of use.
struct SettingsView: View {
    @ObserveInjection var inject
    @AppStorage("waky_dark_mode") private var darkModeEnabled = false

    var body: some View {
        NavigationView {
            List {
                Section {
                    Toggle(isOn: $darkModeEnabled) {
                        Label("Dark mode", systemImage: "moon.fill")
                    }
                    .tint(WakyTheme.accent)
                }

                Section {
                    NavigationLink {
                        PrivacyPolicyView()
                    } label: {
                        Label("Privacy policy", systemImage: "hand.raised.fill")
                    }
                    NavigationLink {
                        TermsOfUseView()
                    } label: {
                        Label("Terms of use", systemImage: "doc.text.fill")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .enableInjection()
        }
        .navigationViewStyle(.stack)
    }
}

// MARK: - Privacy policy (placeholder content)
struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Privacy Policy")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Last updated: \(formattedDate)")
                    .font(.caption)
                    .foregroundColor(WakyTheme.textSecondary)
                Text(privacyPlaceholder)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
        }
        .navigationTitle("Privacy policy")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var formattedDate: String {
        let f = DateFormatter()
        f.dateStyle = .long
        return f.string(from: Date())
    }

    private var privacyPlaceholder: String {
        """
        Waky ("we", "our") respects your privacy. This policy describes how we collect, use, and protect your information when you use the Waky app.

        Information we collect: We store your sleep session data (bedtime, wake time, and session duration) locally on your device. We do not transmit this data to our servers unless you explicitly opt in to a future sync or backup feature.

        Notifications: With your permission, we may send you local notifications to remind you of your chosen bedtime. These are processed on your device.

        Data retention: Your session history is stored on your device. You can clear it by deleting the app.

        Contact: For privacy-related questions, contact us at the support address provided in the app.
        """
    }
}

// MARK: - Terms of use (placeholder content)
struct TermsOfUseView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Terms of Use")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Last updated: \(formattedDate)")
                    .font(.caption)
                    .foregroundColor(WakyTheme.textSecondary)
                Text(termsPlaceholder)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
        }
        .navigationTitle("Terms of use")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var formattedDate: String {
        let f = DateFormatter()
        f.dateStyle = .long
        return f.string(from: Date())
    }

    private var termsPlaceholder: String {
        """
        By using the Waky app, you agree to these terms.

        Use of the app: Waky is a sleep planning and tracking tool. It is not a substitute for professional medical or sleep advice. Use the app for personal, non-commercial purposes.

        Subscription: If you subscribe to Waky, your subscription is subject to the terms of the platform (e.g. App Store) through which you subscribed. Cancellation and refunds are handled by the platform.

        Limitation of liability: We provide the app "as is." We are not liable for any decisions you make based on the app's suggestions or for any loss or damage arising from your use of the app.

        Changes: We may update these terms from time to time. Continued use of the app after changes constitutes acceptance of the updated terms.

        Contact: For questions about these terms, contact us at the support address provided in the app.
        """
    }
}

#Preview {
    SettingsView()
}
