import SwiftUI
import Inject

// MARK: - Hook reasons (what brings you here)
enum OnboardingHookReason: String, CaseIterable, Identifiable {
    case cantSleepOnTime = "I can't go to sleep on time"
    case dontKnowWhen = "I don't know when to go to sleep"
    case wakeUpTired = "I wake up tired"
    case betterRoutine = "I want to build a better sleep routine"
    case justExploring = "Just exploring"

    var id: String { rawValue }
}

struct OnboardingHookView: View {
    @ObserveInjection var inject
    @Binding var onboardingStep: Int
    @State private var selectedReasons: Set<OnboardingHookReason> = []

    var body: some View {
        ZStack {
            WakyTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {
                    // Welcome
                    VStack(spacing: 16) {
                        Image("AppIconImage")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                        Text("Welcome to Waky")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(WakyTheme.textPrimary)
                        Text("What brings you here?")
                            .font(.title3)
                            .foregroundColor(WakyTheme.textSecondary)
                    }
                    .padding(.top, 16)
                    .multilineTextAlignment(.center)

                    // Multiple choice cards
                    VStack(spacing: 12) {
                        ForEach(OnboardingHookReason.allCases) { reason in
                            HookOptionRow(
                                title: reason.rawValue,
                                isSelected: selectedReasons.contains(reason)
                            ) {
                                if selectedReasons.contains(reason) {
                                    selectedReasons.remove(reason)
                                } else {
                                    selectedReasons.insert(reason)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Continue
                    Button(action: continueTapped) {
                        Text("Continue")
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

    private func continueTapped() {
        let reasonsArray = selectedReasons.map(\.rawValue)
        UserDefaults.standard.set(reasonsArray, forKey: "waky_onboarding_reasons")
        onboardingStep = 1
    }
}

// MARK: - Option row (card style, tappable)
private struct HookOptionRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(WakyTheme.textPrimary)
                    .multilineTextAlignment(.leading)
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isSelected ? WakyTheme.accent : WakyTheme.textSecondary.opacity(0.6))
            }
            .padding(WakyTheme.cardPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? WakyTheme.cardBackgroundSelected : WakyTheme.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: WakyTheme.cornerRadius)
                    .stroke(isSelected ? WakyTheme.accent.opacity(0.6) : WakyTheme.textSecondary.opacity(0.2), lineWidth: isSelected ? 2 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: WakyTheme.cornerRadius))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    OnboardingHookView(onboardingStep: .constant(0))
}
