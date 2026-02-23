import SwiftUI
import Inject

private let confirmedBedtimeKey = "waky_confirmed_bedtime"
private let confirmedWakeTimeKey = "waky_confirmed_wake_time"

// MARK: - Home tab container: shows either bedtime selection or home dashboard
struct HomeContainerView: View {
    @ObserveInjection var inject
    @ObservedObject var sessionStore: SessionStore
    @AppStorage(confirmedBedtimeKey) private var confirmedBedtimeInterval: Double = 0
    @AppStorage(confirmedWakeTimeKey) private var confirmedWakeTimeInterval: Double = 0
    @AppStorage("waky_username") private var username: String = "Me"
    @State private var showCommitContract: Bool = false
    @State private var showSleepSession: Bool = false
    @State private var sessionWindow: (start: Date, end: Date)?
    @State private var showSessionResultPopup: Bool = false
    @State private var pendingResultDuration: TimeInterval = 0

    private var hasConfirmedBedtime: Bool {
        confirmedBedtimeInterval > 0 && confirmedWakeTimeInterval > 0
    }
    private var confirmedBedtime: Date { Date(timeIntervalSince1970: confirmedBedtimeInterval) }
    private var confirmedWakeTime: Date { Date(timeIntervalSince1970: confirmedWakeTimeInterval) }

    var body: some View {
        Group {
            if hasConfirmedBedtime {
                HomeView(
                    bedtime: confirmedBedtime,
                    onCommit: { showCommitContract = true },
                    onChangeBedtime: {
                        confirmedBedtimeInterval = 0
                        confirmedWakeTimeInterval = 0
                    }
                )
            } else {
                BedtimeSelectionView(onConfirm: { wakeTime, bedtime in
                    confirmedWakeTimeInterval = wakeTime.timeIntervalSince1970
                    confirmedBedtimeInterval = bedtime.timeIntervalSince1970
                    SleepReminderNotification.requestPermissionIfNeeded { _ in
                        SleepReminderNotification.schedulePrepareForSleepForNextOccurrence(bedtime: bedtime)
                    }
                })
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(WakyTheme.background)
        .sheet(isPresented: $showCommitContract) {
            CommitFlowView(
                isPresented: $showCommitContract,
                username: $username,
                bedtime: confirmedBedtime,
                onCommitted: {
                    sessionWindow = (start: confirmedBedtime, end: confirmedWakeTime)
                    sessionStore.startSession(intendedStart: confirmedBedtime, intendedEnd: confirmedWakeTime)
                    SleepReminderNotification.requestPermissionIfNeeded { _ in
                        SleepReminderNotification.schedulePrepareForSleep(bedtime: confirmedBedtime)
                    }
                    showSleepSession = true
                }
            )
        }
        .fullScreenCover(isPresented: $showSleepSession) {
            if let window = sessionWindow {
                SleepSessionView(
                    sessionStart: window.start,
                    sessionEnd: window.end,
                    sessionStore: sessionStore,
                    onDismiss: {
                        sessionWindow = nil
                        showSleepSession = false
                    }
                )
            }
        }
        .onAppear {
            handlePendingSessionFromOnboarding()
            if hasConfirmedBedtime {
                SleepReminderNotification.requestPermissionIfNeeded { _ in
                    SleepReminderNotification.schedulePrepareForSleepForNextOccurrence(bedtime: confirmedBedtime)
                }
            }
        }
        .onChange(of: sessionStore.lastCompletedSessionDuration) { newValue in
            if let duration = newValue {
                pendingResultDuration = duration
                showSessionResultPopup = true
            }
        }
        .sheet(isPresented: $showSessionResultPopup, onDismiss: {
            sessionStore.clearLastCompletedSessionDuration()
        }) {
            SessionResultPopupView(durationSeconds: pendingResultDuration) {
                showSessionResultPopup = false
                sessionStore.clearLastCompletedSessionDuration()
            }
        }
        .enableInjection()
    }

    /// After onboarding subscribe: treat pending session as confirmed bedtime only. Do not auto-start the sleep session — user taps "I commit" on Home when ready.
    private func handlePendingSessionFromOnboarding() {
        let defaults = UserDefaults.standard
        let startKey = "waky_pending_session_start"
        let endKey = "waky_pending_session_end"
        guard defaults.object(forKey: startKey) != nil, defaults.object(forKey: endKey) != nil else { return }
        let bedtime = Date(timeIntervalSince1970: defaults.double(forKey: startKey))
        let wakeTime = Date(timeIntervalSince1970: defaults.double(forKey: endKey))
        defaults.removeObject(forKey: startKey)
        defaults.removeObject(forKey: endKey)
        // Save as confirmed bedtime so Home shows "My bedtime" and the time; notifications will be scheduled when they tap "I commit"
        confirmedBedtimeInterval = bedtime.timeIntervalSince1970
        confirmedWakeTimeInterval = wakeTime.timeIntervalSince1970
    }
}

// MARK: - Select wake time + fall asleep by, then confirm bedtime
struct BedtimeSelectionView: View {
    @ObserveInjection var inject
    var onConfirm: (Date, Date) -> Void
    @State private var wakeTime: Date = BedtimeSelectionView.nextDefaultWakeTime()
    @State private var selectedCycleIndex: Int = 0

    private var bedtimes: [(date: Date, cycles: Int, sleepMinutes: Int)] {
        WakeTimeCalculator.recommendedBedtimes(for: wakeTime)
    }

    static func nextDefaultWakeTime() -> Date {
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

                Button(action: {
                    onConfirm(wakeTime, bedtimes[selectedCycleIndex].date)
                }) {
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
        .enableInjection()
    }
}

// MARK: - Home screen: My bedtime + time + I commit
struct HomeView: View {
    @ObserveInjection var inject
    let bedtime: Date
    var onCommit: () -> Void
    var onChangeBedtime: () -> Void

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

            Button(action: onCommit) {
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

            Button(action: onChangeBedtime) {
                Text("Change bedtime")
                    .font(.subheadline)
                    .foregroundColor(WakyTheme.textSecondary)
            }
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .enableInjection()
    }
}

// MARK: - Session result popup (Excellent / Good enough / Not enough)
struct SessionResultPopupView: View {
    var durationSeconds: TimeInterval
    var onDismiss: () -> Void

    private var durationHours: Double { durationSeconds / 3600 }
    private var resultType: ResultType {
        if durationHours >= 8 { return .excellent }
        if durationHours >= 7 { return .goodEnough }
        return .notEnough
    }

    private enum ResultType {
        case excellent   // 8h+
        case goodEnough  // 7h to <8h
        case notEnough   // <7h
    }

    private var title: String {
        switch resultType {
        case .excellent: return "Excellent"
        case .goodEnough: return "Good enough"
        case .notEnough: return "Not enough"
        }
    }

    private var message: String {
        switch resultType {
        case .excellent:
            return "Outstanding! You slept \(SleepSession.formatDuration(durationSeconds)). You're giving your body and mind the recovery they need—your health, mood, and performance will thank you."
        case .goodEnough:
            return "You should be proud of yourself. Congratulations—not only do you improve your health, you also improve your performance, mood, and well‑being. Keep it up!"
        case .notEnough:
            return "Could be better: you slept under 7 hours. We know sleep can be hard sometimes. Don't give up—try winding down earlier, limit screens before bed, and stick to a consistent bedtime. Every small step counts."
        }
    }

    private var iconName: String {
        switch resultType {
        case .excellent: return "star.fill"
        case .goodEnough: return "hand.thumbsup.fill"
        case .notEnough: return "moon.zzz.fill"
        }
    }

    private var accentColor: Color {
        switch resultType {
        case .excellent: return WakyTheme.accent
        case .goodEnough: return WakyTheme.accent.opacity(0.9)
        case .notEnough: return WakyTheme.textSecondary
        }
    }

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: iconName)
                .font(.system(size: 48))
                .foregroundStyle(accentColor)
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(WakyTheme.textPrimary)
            Text(message)
                .font(.subheadline)
                .foregroundColor(WakyTheme.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal)
            Button(action: onDismiss) {
                Text("OK")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(WakyTheme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: WakyTheme.cornerRadius))
            }
            .padding(.top, 8)
        }
        .padding(28)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(WakyTheme.background)
    }
}

struct BedtimeRow: View {
    let bedtime: Date
    let cycles: Int
    let sleepMinutes: Int
    let isSelected: Bool
    let onTap: () -> Void
    
    private var sleepLabel: String {
        let h = sleepMinutes / 60
        let m = sleepMinutes % 60
        if m == 0 { return "\(h)h sleep" }
        return "\(h)h \(m)m sleep"
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(bedtime, style: .time)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(WakyTheme.textPrimary)
                    Text("\(cycles) cycles · \(sleepLabel)")
                        .font(.caption)
                        .foregroundColor(WakyTheme.textSecondary)
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(WakyTheme.accent)
                }
            }
            .padding(WakyTheme.cardPadding)
            .background(isSelected ? WakyTheme.cardBackgroundSelected : WakyTheme.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: WakyTheme.cornerRadius)
                    .stroke(isSelected ? WakyTheme.accent : Color.clear, lineWidth: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: WakyTheme.cornerRadius))
        }
        .buttonStyle(.plain)
    }
}

#Preview("Home container") {
    HomeContainerView(sessionStore: SessionStore())
}
#Preview("Bedtime selection") {
    BedtimeSelectionView(onConfirm: { _, _ in })
}
#Preview("Home") {
    HomeView(bedtime: Date(), onCommit: {}, onChangeBedtime: {})
}
