import SwiftUI
import Inject

struct ContentView: View {
    @ObserveInjection var inject
    @StateObject private var sessionStore = SessionStore()
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("waky_onboarding_step") private var onboardingStep = 0
    @AppStorage("waky_dark_mode") private var darkModeEnabled = false

    private let onboardingTotalSteps = 3

    private var showOnboarding: Bool {
        onboardingStep < onboardingTotalSteps
    }

    var body: some View {
        Group {
            if !showOnboarding {
                MainTabView(sessionStore: sessionStore)
            } else {
                VStack(spacing: 0) {
                    OnboardingProgressBar(currentStep: onboardingStep, totalSteps: onboardingTotalSteps)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        .padding(.bottom, 8)
                    if onboardingStep == 0 {
                        OnboardingHookView(onboardingStep: $onboardingStep)
                    } else if onboardingStep == 1 {
                        OnboardingExplainView(onboardingStep: $onboardingStep)
                    } else {
                        OnboardingAppPreviewView(onboardingStep: $onboardingStep)
                    }
                }
                .background(WakyTheme.background)
            }
        }
            .preferredColorScheme(darkModeEnabled ? .dark : .light)
            .onAppear {
                if onboardingStep >= onboardingTotalSteps {
                    SleepReminderNotification.requestPermissionIfNeeded()
                }
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .background {
                    sessionStore.saveActiveSession()
                }
            }
            .enableInjection()
    }
}

#Preview {
    ContentView()
}
