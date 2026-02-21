import SwiftUI
import Inject

struct SleepSessionView: View {
    @ObserveInjection var inject
    let sessionStart: Date
    let sessionEnd: Date
    @ObservedObject var sessionStore: SessionStore
    var onDismiss: () -> Void
    
    @State private var quoteIndex: Int = 0
    @State private var showEndSessionPopup: Bool = false
    @State private var showWelcomeMessage: Bool = false
    
    private var sessionTimeRangeText: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: sessionStart)) → \(formatter.string(from: sessionEnd))"
    }
    
    private let sleepQuotes = [
        "Sleep is the best meditation.",
        "A good laugh and a long sleep are the best cures.",
        "The best bridge between despair and hope is a good night’s sleep.",
        "Sleep is the golden chain that ties health and our bodies together.",
        "We are such stuff as dreams are made on.",
    ]
    
    private let floatAmplitude: CGFloat = 10
    private let floatSpeed: Double = 1.8
    
    var body: some View {
        ZStack {
            WakyTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 48) {
                Spacer()
                
                // Session window (e.g. "9:00 PM → 6:00 AM")
                Text(sessionTimeRangeText)
                    .font(.subheadline)
                    .foregroundColor(WakyTheme.textSecondary.opacity(0.8))
                    .padding(.bottom, 8)
                
                // z z z z z — floating animation
                TimelineView(.animation(minimumInterval: 1/30)) { context in
                    let t = context.date.timeIntervalSinceReferenceDate
                    HStack(spacing: 14) {
                        ForEach(0..<5, id: \.self) { i in
                            Text("z")
                                .font(.system(size: 44, weight: .light))
                                .foregroundColor(WakyTheme.textSecondary)
                                .opacity(0.5 + 0.35 * sin(t * 1.2 + Double(i) * 0.9))
                                .offset(y: CGFloat(sin(t * floatSpeed + Double(i) * 0.8)) * floatAmplitude)
                        }
                    }
                }
                .padding(.bottom, 8)
                
                // Quote
                Text(sleepQuotes[quoteIndex])
                    .font(.subheadline)
                    .italic()
                    .foregroundColor(WakyTheme.textSecondary.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .frame(minHeight: 60)
                
                Spacer()
                
                Text("Tap to end session")
                    .font(.caption)
                    .foregroundColor(WakyTheme.textSecondary.opacity(0.5))
                    .padding(.bottom, 48)
            }
        }
        .overlay {
            if showWelcomeMessage {
                welcomeOverlay
            }
        }
        .overlay {
            if showEndSessionPopup {
                EndSessionPopupView(
                    sessionStart: sessionStore.currentSession?.actualStart,
                    intendedWindow: (sessionStart, sessionEnd),
                    onStay: { showEndSessionPopup = false },
                    onEndSession: {
                        showEndSessionPopup = false
                        sessionStore.recordActualEndAndComplete()
                        onDismiss()
                    }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.92)))
                .zIndex(100)
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: showEndSessionPopup)
        .onAppear {
            sessionStore.recordActualStart()
            startQuoteRotation()
            withAnimation(.easeOut(duration: 0.7)) {
                showWelcomeMessage = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.easeOut(duration: 0.8)) {
                    showWelcomeMessage = false
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            showEndSessionPopup = true
        }
        .enableInjection()
    }
    
    private var welcomeOverlay: some View {
        VStack(spacing: 12) {
            Image(systemName: "moon.zzz.fill")
                .font(.system(size: 32))
                .foregroundStyle(WakyTheme.accent)
            Text("You deserved that rest. Close your phone and sleep well.")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(WakyTheme.textPrimary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 20)
        .background(WakyTheme.background.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: WakyTheme.cornerRadiusLarge))
        .shadow(color: .black.opacity(0.15), radius: 16, x: 0, y: 6)
        .padding(.horizontal, 40)
        .opacity(showWelcomeMessage ? 1 : 0)
        .scaleEffect(showWelcomeMessage ? 1 : 0.92)
        .animation(.easeOut(duration: 0.5), value: showWelcomeMessage)
    }
    
    private func startQuoteRotation() {
        _ = Timer.scheduledTimer(withTimeInterval: 12, repeats: true) { _ in
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.6)) {
                    quoteIndex = (quoteIndex + 1) % sleepQuotes.count
                }
            }
        }
    }
}

// MARK: - Expressive popup when user taps to leave sleep session
struct EndSessionPopupView: View {
    var sessionStart: Date?
    var intendedWindow: (start: Date, end: Date)?
    var onStay: () -> Void
    var onEndSession: () -> Void

    private var sessionDurationText: String? {
        guard let start = sessionStart else { return nil }
        return SleepSession.formatDuration(Date().timeIntervalSince(start))
    }

    private var intendedWindowText: String? {
        guard let window = intendedWindow else { return nil }
        let f = DateFormatter()
        f.timeStyle = .short
        return "\(f.string(from: window.start)) → \(f.string(from: window.end))"
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture(perform: onStay)
            
            VStack(spacing: 20) {
                Text("😴")
                    .font(.system(size: 44))
                
                Text("Leaving already?")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(WakyTheme.textPrimary)
                
                if let duration = sessionDurationText {
                    VStack(spacing: 6) {
                        Text("This session: \(duration)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(WakyTheme.accent)
                        if let window = intendedWindowText {
                            Text("Planned: \(window)")
                                .font(.caption)
                                .foregroundColor(WakyTheme.textSecondary)
                        }
                    }
                }
                
                Text("Your future well-rested self might miss you… but it’s your call.")
                    .font(.subheadline)
                    .foregroundColor(WakyTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal)
                
                HStack(spacing: 12) {
                    Button(action: onStay) {
                        Text("Stay")
                            .fontWeight(.semibold)
                            .foregroundColor(WakyTheme.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(WakyTheme.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: WakyTheme.cornerRadius))
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: onEndSession) {
                        Text("End session")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(WakyTheme.accent)
                            .clipShape(RoundedRectangle(cornerRadius: WakyTheme.cornerRadius))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(28)
            .background(WakyTheme.background)
            .clipShape(RoundedRectangle(cornerRadius: WakyTheme.cornerRadiusLarge))
            .shadow(color: .black.opacity(0.15), radius: 24, x: 0, y: 8)
            .padding(.horizontal, 32)
        }
    }
}

#Preview("End session popup") {
    let start = Calendar.current.date(byAdding: .hour, value: -2, to: Date())!
    let end = Calendar.current.date(byAdding: .hour, value: 6, to: start)!
    return EndSessionPopupView(
        sessionStart: start,
        intendedWindow: (start, end),
        onStay: {},
        onEndSession: {}
    )
}

#Preview {
    SleepSessionView(
        sessionStart: Date(),
        sessionEnd: Date(),
        sessionStore: SessionStore(),
        onDismiss: {}
    )
}
