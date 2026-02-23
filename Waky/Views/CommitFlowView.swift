import SwiftUI
import Inject
import FamilyControls

/// Two-step commit flow: (1) Choose apps to block during sleep, (2) Sleep contract + sign.
struct CommitFlowView: View {
    @ObserveInjection var inject
    @Binding var isPresented: Bool
    @Binding var username: String
    var bedtime: Date
    var onCommitted: () -> Void

    @StateObject private var appBlockManager = AppBlockManager.shared
    @State private var step: Int = 1
    @State private var selection = FamilyActivitySelection()
    @State private var isRequestingAuth = false

    var body: some View {
        Group {
            if step == 1 {
                blockAppsStep
            } else {
                contractStep
                    .overlay(alignment: .topLeading) {
                        Button {
                            step = 1
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                            .font(.body.weight(.medium))
                            .foregroundColor(WakyTheme.accent)
                            .padding(.leading, 16)
                            .padding(.top, 56)
                        }
                    }
            }
        }
        .onAppear {
            if let saved = appBlockManager.savedSelection {
                selection = saved
            }
            // Ask for notification permission when user opens commit flow so wind-down reminders can be scheduled
            SleepReminderNotification.requestPermissionIfNeeded()
        }
        .enableInjection()
    }

    // MARK: - Step 1: Apps to block
    private var blockAppsStep: some View {
        VStack(spacing: 0) {
            Text("Block apps during sleep")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(WakyTheme.textPrimary)
                .padding(.top, 24)
            Text("Choose apps you want to block until you wake (e.g. TikTok, Instagram). You can skip this step.")
                .font(.subheadline)
                .foregroundColor(WakyTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.top, 8)
            Text("We'll also remind you 1 hour and 30 minutes before your chosen bedtime.")
                .font(.caption)
                .foregroundColor(WakyTheme.textSecondary.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.top, 4)

            if #available(iOS 16.0, *) {
                switch appBlockManager.authorizationStatus {
                case .notDetermined:
                    VStack(spacing: 20) {
                        Button {
                            requestAuthorization()
                        } label: {
                            HStack {
                                Label("Allow access to choose apps", systemImage: "lock.open.fill")
                                if isRequestingAuth { Spacer(); ProgressView() }
                            }
                        }
                        .disabled(isRequestingAuth)
                        .padding(.top, 24)
                        skipAndContinueButton
                    }
                case .denied:
                    Text("Screen Time access was denied. You can enable it in Settings later.")
                        .font(.caption)
                        .foregroundColor(WakyTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding()
                    skipAndContinueButton
                case .approved:
                    VStack(spacing: 0) {
                        FamilyActivityPicker(selection: $selection)
                            .onChange(of: selection) { newValue in
                                appBlockManager.savedSelection = newValue
                            }
                        skipAndContinueButton
                    }
                @unknown default:
                    skipAndContinueButton
                }
            } else {
                skipAndContinueButton
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(WakyTheme.background)
    }

    private var skipAndContinueButton: some View {
        Button(action: goToContract) {
            Text("Continue to contract")
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(WakyTheme.accent)
                .clipShape(RoundedRectangle(cornerRadius: WakyTheme.cornerRadiusLarge))
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 32)
    }

    private func requestAuthorization() {
        guard #available(iOS 16.0, *) else { return }
        isRequestingAuth = true
        Task { @MainActor in
            await appBlockManager.requestAuthorization()
            isRequestingAuth = false
        }
    }

    private func goToContract() {
        let hasSelection = !selection.applicationTokens.isEmpty || !selection.categoryTokens.isEmpty
        if hasSelection {
            appBlockManager.isBlockingEnabled = true
            appBlockManager.savedSelection = selection
            appBlockManager.applyShield(using: selection)
        } else {
            appBlockManager.savedSelection = selection
        }
        step = 2
    }

    // MARK: - Step 2: Sleep contract
    private var contractStep: some View {
        CommitContractView(
            isPresented: $isPresented,
            username: $username,
            bedtime: bedtime,
            onCommitted: onCommitted
        )
    }
}
