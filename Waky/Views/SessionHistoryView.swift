import SwiftUI
import Inject

/// Session tracking tab: history of all sleep sessions and average sleep time.
struct SessionHistoryView: View {
    @ObserveInjection var inject
    @ObservedObject var sessionStore: SessionStore

    /// Sessions with a valid actual duration (for average).
    private var sessionsWithDuration: [SleepSession] {
        sessionStore.completedSessions.filter { $0.sessionDuration() != nil }
    }

    private var averageSleepSeconds: TimeInterval? {
        let durations = sessionsWithDuration.compactMap { $0.sessionDuration() }
        guard !durations.isEmpty else { return nil }
        return durations.reduce(0, +) / Double(durations.count)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Session history")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(WakyTheme.textPrimary)
                    .padding(.top, 8)

                // Average sleep time card
                if let avg = averageSleepSeconds {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "chart.bar.fill")
                                .font(.title3)
                                .foregroundColor(WakyTheme.accent)
                            Text("Average sleep")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(WakyTheme.textSecondary)
                        }
                        Text(SleepSession.formatDuration(avg))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(WakyTheme.textPrimary)
                        Text("Across \(sessionsWithDuration.count) session\(sessionsWithDuration.count == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundColor(WakyTheme.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(WakyTheme.cardPadding)
                    .background(WakyTheme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: WakyTheme.cornerRadius))
                }

                // Session list
                VStack(alignment: .leading, spacing: 12) {
                    Text("All sessions")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(WakyTheme.textSecondary)

                    if sessionStore.completedSessions.isEmpty {
                        Text("Complete a sleep session to see your history here.")
                            .font(.subheadline)
                            .foregroundColor(WakyTheme.textSecondary.opacity(0.9))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(WakyTheme.cardPadding)
                    } else {
                        ForEach(sessionStore.completedSessions) { session in
                            SessionHistoryRow(session: session)
                        }
                    }
                }
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(WakyTheme.background)
        .enableInjection()
    }
}

// MARK: - Single session row
private struct SessionHistoryRow: View {
    let session: SleepSession

    private var dateText: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: session.intendedStart)
    }

    private var timeRangeText: String {
        let f = DateFormatter()
        f.timeStyle = .short
        return "\(f.string(from: session.intendedStart)) → \(f.string(from: session.intendedEnd))"
    }

    private var durationText: String? {
        session.sessionDuration().map { SleepSession.formatDuration($0) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(dateText)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(WakyTheme.textPrimary)
            Text(timeRangeText)
                .font(.caption)
                .foregroundColor(WakyTheme.textSecondary)
            if let dur = durationText {
                HStack(spacing: 4) {
                    Image(systemName: "moon.zzz.fill")
                        .font(.caption2)
                    Text(dur)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(WakyTheme.accent)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(WakyTheme.cardPadding)
        .background(WakyTheme.cardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: WakyTheme.cornerRadius)
                .stroke(WakyTheme.textSecondary.opacity(0.2), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: WakyTheme.cornerRadius))
    }
}

#Preview {
    SessionHistoryView(sessionStore: SessionStore())
}
