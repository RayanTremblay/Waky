import SwiftUI
import Inject

/// Second onboarding screen: explains how the app works.
struct OnboardingExplainView: View {
    @ObserveInjection var inject
    @Binding var onboardingStep: Int

    var body: some View {
        ZStack {
            WakyTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {
                    // Title
                    VStack(spacing: 10) {
                        Text("How Waky works")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(WakyTheme.textPrimary)
                        Text("Simple steps to wake up at the right time")
                            .font(.subheadline)
                            .foregroundColor(WakyTheme.textSecondary)
                    }
                    .padding(.top, 16)
                    .multilineTextAlignment(.center)

                    // Explanation card
                    VStack(alignment: .leading, spacing: 16) {
                        ExplainRow(
                            number: 1,
                            title: "Pick your wake time",
                            detail: "Choose when you want to get up in the morning."
                        )
                        ExplainRow(
                            number: 2,
                            title: "Get your bedtime",
                            detail: "Waky uses 90-minute sleep cycles to suggest when to fall asleep so you wake between cycles—not in the middle of one—and feel less groggy."
                        )
                        ExplainRow(
                            number: 3,
                            title: "Commit & sleep",
                            detail: "Commit to your bedtime, keep your phone on the sleep screen during the night, and wake at your chosen time."
                        )
                    }
                    .padding(WakyTheme.cardPadding)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(WakyTheme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: WakyTheme.cornerRadius)
                            .stroke(WakyTheme.textSecondary.opacity(0.2), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: WakyTheme.cornerRadius))
                    .padding(.horizontal, 20)

                    // Continue
                    Button(action: { onboardingStep = 2 }) {
                        Text("Get started")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(WakyTheme.accent)
                            .clipShape(RoundedRectangle(cornerRadius: WakyTheme.cornerRadius))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
            }
        }
        .enableInjection()
    }
}

// MARK: - Numbered row
private struct ExplainRow: View {
    let number: Int
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Text("\(number)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(WakyTheme.accent)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(WakyTheme.textPrimary)
                Text(detail)
                    .font(.footnote)
                    .foregroundColor(WakyTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview {
    OnboardingExplainView(onboardingStep: .constant(1))
}
