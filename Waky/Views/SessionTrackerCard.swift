import SwiftUI
import Inject

/// Card on the main screen showing last session and session count / streak.
struct SessionTrackerCard: View {
    @ObserveInjection var inject
    let lastSession: SleepSession?
    let totalSessions: Int
    
    private var timeRangeText: String? {
        guard let s = lastSession else { return nil }
        let f = DateFormatter()
        f.timeStyle = .short
        return "\(f.string(from: s.intendedStart)) → \(f.string(from: s.intendedEnd))"
    }
    
    private var lastSessionDateText: String? {
        guard let s = lastSession else { return nil }
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: s.intendedStart)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "moon.zzz.fill")
                    .font(.title3)
                    .foregroundColor(WakyTheme.accent)
                Text("Session tracker")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(WakyTheme.textSecondary)
            }
            
            if let last = lastSession, let range = timeRangeText, let dateText = lastSessionDateText {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Last session")
                        .font(.caption)
                        .foregroundColor(WakyTheme.textSecondary.opacity(0.9))
                    Text(range)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(WakyTheme.textPrimary)
                    Text(dateText)
                        .font(.caption2)
                        .foregroundColor(WakyTheme.textSecondary.opacity(0.8))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    Label("\(totalSessions) session\(totalSessions == 1 ? "" : "s")", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(WakyTheme.accent)
                }
            } else {
                Text("Complete a sleep session to see your progress here.")
                    .font(.subheadline)
                    .foregroundColor(WakyTheme.textSecondary.opacity(0.9))
            }
        }
        .padding(WakyTheme.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WakyTheme.cardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: WakyTheme.cornerRadius)
                .stroke(WakyTheme.textSecondary.opacity(0.2), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: WakyTheme.cornerRadius))
        .enableInjection()
    }
}

#Preview {
    SessionTrackerCard(lastSession: nil, totalSessions: 0)
        .padding()
}
