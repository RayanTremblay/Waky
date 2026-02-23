import SwiftUI
import Inject

/// Onboarding step 3: Home preview — "My bedtime", time, "I commit". I commit → commit flow → paywall (no session start).
struct OnboardingHomeView: View {
    @ObserveInjection var inject
    @Binding var onboardingStep: Int
    @AppStorage("waky_confirmed_bedtime") private var confirmedBedtimeInterval: Double = 0
    @AppStorage("waky_confirmed_wake_time") private var confirmedWakeTimeInterval: Double = 0
    @AppStorage("waky_username") private var username: String = "Me"
    @State private var showCommitContract: Bool = false
    @State private var showPaywall: Bool = false

    private var bedtime: Date {
        Date(timeIntervalSince1970: confirmedBedtimeInterval)
    }
    private var bedtimeTimeText: String {
        let f = DateFormatter()
        f.timeStyle = .short
        return f.string(from: bedtime)
    }

    var body: some View {
        VStack(spacing: 0) {
            Text("My bedtime")
                .font(.headline)
                .foregroundColor(WakyTheme.textSecondary)
                .padding(.top, 32)

            Text(bedtimeTimeText)
                .font(.system(size: 56, weight: .light))
                .foregroundColor(WakyTheme.textPrimary)
                .padding(.top, 24)
                .frame(maxWidth: .infinity)

            Spacer()

            Button(action: { showCommitContract = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "hand.raised.fill")
                    Text("I commit")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(WakyTheme.accent)
                .clipShape(RoundedRectangle(cornerRadius: WakyTheme.cornerRadiusLarge))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(WakyTheme.background)
        .sheet(isPresented: $showCommitContract) {
            CommitFlowView(
                isPresented: $showCommitContract,
                username: $username,
                bedtime: bedtime,
                onCommitted: {
                    showCommitContract = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        showPaywall = true
                    }
                }
            )
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(
                onSubscribe: {
                    showPaywall = false
                    onboardingStep = 4
                },
                subscribeOnly: true
            )
        }
        .enableInjection()
    }
}

#Preview {
    OnboardingHomeView(onboardingStep: .constant(3))
}
