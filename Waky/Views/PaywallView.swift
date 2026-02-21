import SwiftUI
import Inject

enum PaywallPlan: String, CaseIterable {
    case yearly
    case monthly
}

/// Paywall shown after signing the contract during onboarding (or when not subscribed).
/// Two options: yearly (3-day trial, $19.99/year, default) and monthly ($9.99/month). Shows discount for choosing yearly.
/// When `subscribeOnly` is true, only the Subscribe button is shown (no way to dismiss without subscribing).
struct PaywallView: View {
    @ObserveInjection var inject
    var onSubscribe: () -> Void
    var onMaybeLater: (() -> Void)?
    var subscribeOnly: Bool = false

    @State private var selectedPlan: PaywallPlan = .yearly

    private static let yearlyPrice: Double = 19.99
    private static let monthlyPrice: Double = 9.99
    private static let yearlyPricePerMonth: Double = 1.66
    private static var yearlySavingsVsMonthly: Double {
        (monthlyPrice * 12) - yearlyPrice
    }
    private static var yearlySavingsPercent: Int {
        Int(round((yearlySavingsVsMonthly / (monthlyPrice * 12)) * 100))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(WakyTheme.accent)

                Text("Unlock Waky")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(WakyTheme.textPrimary)

                Text("Get the full experience: commit to your bedtime, track your sessions, and wake up at the right time every day.")
                    .font(.subheadline)
                    .foregroundColor(WakyTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Yearly option (default)
                PaywallPlanRow(
                    title: "Yearly",
                    subtitle: "3 days free, then \(formatPrice(Self.yearlyPrice))/year (\(formatPrice(Self.yearlyPricePerMonth))/month)",
                    badge: "Best value",
                    savingsText: "Save \(Self.yearlySavingsPercent)% vs monthly",
                    isSelected: selectedPlan == .yearly
                ) {
                    selectedPlan = .yearly
                }

                // Monthly option
                PaywallPlanRow(
                    title: "Monthly",
                    subtitle: "\(formatPrice(Self.monthlyPrice))/month",
                    badge: nil,
                    savingsText: "Save \(formatPrice(Self.yearlySavingsVsMonthly))/year with yearly",
                    isSelected: selectedPlan == .monthly
                ) {
                    selectedPlan = .monthly
                }

                Button(action: onSubscribe) {
                    Text(selectedPlan == .yearly ? "Start 3-day free trial" : "Subscribe")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(WakyTheme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: WakyTheme.cornerRadius))
                }
                .padding(.top, 8)

                if !subscribeOnly, let onMaybeLater = onMaybeLater {
                    Button(action: onMaybeLater) {
                        Text("Maybe later")
                            .font(.subheadline)
                            .foregroundColor(WakyTheme.textSecondary)
                    }
                    .padding(.top, 4)
                }
            }
            .padding(28)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(WakyTheme.background)
        .enableInjection()
    }

    private func formatPrice(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "$\(value)"
    }
}

// MARK: - Plan row (tappable card)
private struct PaywallPlanRow: View {
    let title: String
    let subtitle: String
    let badge: String?
    let savingsText: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(WakyTheme.textPrimary)
                    if let badge = badge {
                        Text(badge)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(WakyTheme.accent)
                            .clipShape(Capsule())
                    }
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(WakyTheme.accent)
                    }
                }
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(WakyTheme.textSecondary)
                Text(savingsText)
                    .font(.caption)
                    .foregroundColor(WakyTheme.accent)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(WakyTheme.cardPadding)
            .background(isSelected ? WakyTheme.cardBackgroundSelected : WakyTheme.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: WakyTheme.cornerRadius)
                    .stroke(isSelected ? WakyTheme.accent : WakyTheme.textSecondary.opacity(0.2), lineWidth: isSelected ? 2 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: WakyTheme.cornerRadius))
        }
        .buttonStyle(.plain)
    }
}

#Preview("Subscribe only") {
    PaywallView(onSubscribe: {}, subscribeOnly: true)
}
#Preview("With Maybe later") {
    PaywallView(onSubscribe: {}, onMaybeLater: {})
}
