import Foundation

/// A sleep session: intended window (selected bedtime → wake time) and actual start/end when the user opened/closed the sleep screen.
struct SleepSession: Identifiable, Codable {
    let id: UUID
    /// Selected "fall asleep by" time (e.g. 9:00 PM).
    let intendedStart: Date
    /// Selected wake time (e.g. 6:00 AM).
    let intendedEnd: Date
    /// When the user opened the sleep screen (tapped Done).
    var actualStart: Date?
    /// When the user ended the session (tapped to dismiss).
    var actualEnd: Date?
    
    init(id: UUID = UUID(), intendedStart: Date, intendedEnd: Date, actualStart: Date? = nil, actualEnd: Date? = nil) {
        self.id = id
        self.intendedStart = intendedStart
        self.intendedEnd = intendedEnd
        self.actualStart = actualStart
        self.actualEnd = actualEnd
    }

    /// Duration from actual start to actual end (or to now if not ended). Returns nil if no actual start.
    func sessionDuration(from referenceEnd: Date = Date()) -> TimeInterval? {
        guard let start = actualStart else { return nil }
        let end = actualEnd ?? referenceEnd
        return end.timeIntervalSince(start)
    }

    /// Formatted string for display, e.g. "2h 15m" or "45m".
    static func formatDuration(_ seconds: TimeInterval) -> String {
        let totalMinutes = Int(seconds / 60)
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
}

/// Tracks the current session and completed sessions. Session runs from selected bedtime to selected wake time.
final class SessionStore: ObservableObject {
    @Published private(set) var currentSession: SleepSession?
    @Published private(set) var completedSessions: [SleepSession] = []
    /// Set when a session is completed so the UI can show the result popup (duration in seconds). Clear after showing.
    @Published var lastCompletedSessionDuration: TimeInterval?
    
    private let completedKey = "waky_completed_sessions"
    private let activeSessionKey = "waky_active_session"
    
    init() {
        loadCompletedSessions()
        endPersistedSessionIfNeeded()
    }
    
    /// Call when user commits: start a new session with the selected bedtime and wake time.
    func startSession(intendedStart: Date, intendedEnd: Date) {
        currentSession = SleepSession(intendedStart: intendedStart, intendedEnd: intendedEnd)
        saveActiveSession()
    }
    
    /// Call when the sleep screen appears (user tapped Done).
    func recordActualStart() {
        guard var session = currentSession else { return }
        session.actualStart = Date()
        currentSession = session
        saveActiveSession()
    }
    
    /// Call when the user taps to end the session.
    func recordActualEndAndComplete() {
        guard var session = currentSession else { return }
        let actualEnd = Date()
        session.actualEnd = actualEnd
        let start = session.actualStart ?? actualEnd
        lastCompletedSessionDuration = actualEnd.timeIntervalSince(start)
        currentSession = nil
        completedSessions.insert(session, at: 0)
        saveCompletedSessions()
        clearActiveSession()
        SleepReminderNotification.cancel()
    }
    
    func clearLastCompletedSessionDuration() {
        lastCompletedSessionDuration = nil
    }
    
    /// Persist current session when app goes to background (e.g. user locked phone). End it on next launch if they closed the app.
    func saveActiveSession() {
        guard let session = currentSession else { return }
        guard let data = try? JSONEncoder().encode(session) else { return }
        UserDefaults.standard.set(data, forKey: activeSessionKey)
    }
    
    private func clearActiveSession() {
        UserDefaults.standard.removeObject(forKey: activeSessionKey)
    }
    
    /// On launch: if there was an active session (app was closed/killed), end it now.
    private func endPersistedSessionIfNeeded() {
        guard let data = UserDefaults.standard.data(forKey: activeSessionKey),
              let session = try? JSONDecoder().decode(SleepSession.self, from: data) else { return }
        clearActiveSession()
        SleepReminderNotification.cancel()
        var ended = session
        ended.actualEnd = Date()
        completedSessions.insert(ended, at: 0)
        saveCompletedSessions()
    }
    
    private func loadCompletedSessions() {
        guard let data = UserDefaults.standard.data(forKey: completedKey),
              let decoded = try? JSONDecoder().decode([SleepSession].self, from: data) else { return }
        completedSessions = decoded
    }
    
    private func saveCompletedSessions() {
        guard let data = try? JSONEncoder().encode(completedSessions) else { return }
        UserDefaults.standard.set(data, forKey: completedKey)
    }
}
