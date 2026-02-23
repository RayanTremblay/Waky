import SwiftUI
import Inject

/// Onboarding step 2: Select wake time + fall asleep by, then "Confirm bedtime" → saves and goes to home preview (step 3).
struct OnboardingBedtimeSelectionView: View {
    @ObserveInjection var inject
    @Binding var onboardingStep: Int
    @State private var wakeTime: Date = Self.nextDefaultWakeTime()
    @State private var selectedCycleIndex: Int = 0

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
                        ) { selectedCycleIndex = index }
                    }
                }

                Button(action: confirmBedtime) {
                    Text("Confirm bedtime")
                        .fontWeight(.semibold)
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
        .onAppear {
            SleepReminderNotification.requestPermissionIfNeeded()
        }
        .enableInjection()
    }

    private func confirmBedtime() {
        let bedtime = bedtimes[selectedCycleIndex].date
        UserDefaults.standard.set(bedtime.timeIntervalSince1970, forKey: "waky_confirmed_bedtime")
        UserDefaults.standard.set(wakeTime.timeIntervalSince1970, forKey: "waky_confirmed_wake_time")
        SleepReminderNotification.requestPermissionIfNeeded { _ in
            SleepReminderNotification.schedulePrepareForSleepForNextOccurrence(bedtime: bedtime)
        }
        onboardingStep = 3
    }
}

#Preview {
    OnboardingBedtimeSelectionView(onboardingStep: .constant(2))
}
