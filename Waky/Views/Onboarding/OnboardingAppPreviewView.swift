import SwiftUI
import Inject

/// Third onboarding step: shows the real app UI. Commit opens the contract; after signature, paywall (subscribe only).
struct OnboardingAppPreviewView: View {
    @ObserveInjection var inject
    @Binding var onboardingStep: Int
    @AppStorage("waky_username") private var username: String = "Me"
    @State private var wakeTime: Date = Self.nextDefaultWakeTime()
    @State private var selectedCycleIndex: Int = 0
    @State private var showCommitContract: Bool = false
    @State private var showPaywall: Bool = false

    private var bedtimes: [(date: Date, cycles: Int, sleepMinutes: Int)] {
        WakeTimeCalculator.recommendedBedtimes(for: wakeTime)
    }

    private static func nextDefaultWakeTime() -> Date {
        let cal = Calendar.current
        var comps = cal.dateComponents([.year, .month, .day], from: Date())
        comps.hour = 7
        comps.minute = 0
        return cal.date(from: comps) ?? Date()
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                Text("When do you want to wake up?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(WakyTheme.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Wake time")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(WakyTheme.textSecondary)

                    DatePicker("", selection: $wakeTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                }
                .padding(WakyTheme.cardPadding)
                .background(WakyTheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: WakyTheme.cornerRadius))

                VStack(alignment: .leading, spacing: 12) {
                    Text("Fall asleep by")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(WakyTheme.textSecondary)

                    ForEach(Array(bedtimes.enumerated()), id: \.offset) { index, item in
                        BedtimeRow(
                            bedtime: item.date,
                            cycles: item.cycles,
                            sleepMinutes: item.sleepMinutes,
                            isSelected: selectedCycleIndex == index
                        ) {
                            selectedCycleIndex = index
                        }
                    }
                }

                Button(action: { showCommitContract = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "hand.raised.fill")
                        Text("Commit")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(WakyTheme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: WakyTheme.cornerRadiusLarge))
                }
                .padding(.top, 8)

                Spacer(minLength: 40)
            }
            .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(WakyTheme.background)
        .sheet(isPresented: $showCommitContract) {
            let selectedBedtime = bedtimes[selectedCycleIndex].date
            CommitContractView(
                isPresented: $showCommitContract,
                username: $username,
                bedtime: selectedBedtime,
                onCommitted: {
                    showCommitContract = false
                    // Present paywall after contract sheet has finished dismissing (SwiftUI won’t show a new sheet while one is dismissing)
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
                    onboardingStep = 3
                },
                subscribeOnly: true
            )
        }
        .enableInjection()
    }
}

#Preview {
    OnboardingAppPreviewView(onboardingStep: .constant(2))
}
