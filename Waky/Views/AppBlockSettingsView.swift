import SwiftUI
import Inject
import FamilyControls

/// Screen to authorize Screen Time, pick apps to block (e.g. TikTok, Instagram), and toggle blocking on/off.
struct AppBlockSettingsView: View {
    @ObserveInjection var inject
    @StateObject private var manager = AppBlockManager.shared
    @State private var isRequestingAuth = false
    @State private var authError: String?

    var body: some View {
        List {
            Section {
                switch manager.authorizationStatus {
                case .notDetermined:
                    Button {
                        requestAuthorization()
                    } label: {
                        HStack {
                            Label("Allow access to choose apps", systemImage: "lock.open.fill")
                            Spacer()
                            if isRequestingAuth {
                                ProgressView()
                            }
                        }
                    }
                    .disabled(isRequestingAuth)
                    if let error = authError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                case .denied:
                    Text("Screen Time access was denied. You can enable it in Settings → Screen Time.")
                        .font(.subheadline)
                        .foregroundColor(WakyTheme.textSecondary)
                case .approved:
                    NavigationLink {
                        AppBlockPickerView()
                    } label: {
                        HStack {
                            Label("Choose apps to block", systemImage: "app.badge.fill")
                            if manager.hasSelectedApps {
                                Spacer()
                                Text("Selected")
                                    .font(.caption)
                                    .foregroundColor(WakyTheme.accent)
                            }
                        }
                    }

                    if manager.hasSelectedApps {
                        Toggle(isOn: Binding(
                            get: { manager.isBlockingEnabled },
                            set: { manager.isBlockingEnabled = $0 }
                        )) {
                            Label("Block selected apps", systemImage: "hand.raised.fill")
                        }
                        .tint(WakyTheme.accent)
                    }
                @unknown default:
                    EmptyView()
                }
            }
        }
        .navigationTitle("Block apps")
        .navigationBarTitleDisplayMode(.inline)
        .enableInjection()
    }

    private func requestAuthorization() {
        guard #available(iOS 16.0, *) else { return }
        isRequestingAuth = true
        authError = nil
        Task { @MainActor in
            await manager.requestAuthorization()
            isRequestingAuth = false
            if manager.authorizationStatus != .approved {
                authError = "Access was not granted."
            }
        }
    }
}

// MARK: - Full-screen picker (avoids List + picker layout/search bugs)
struct AppBlockPickerView: View {
    @StateObject private var manager = AppBlockManager.shared
    @State private var selection = FamilyActivitySelection()

    var body: some View {
        VStack(spacing: 0) {
            Text("Tap apps or categories to select (e.g. TikTok, Instagram, Social Networking).")
                .font(.subheadline)
                .foregroundColor(WakyTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(WakyTheme.cardBackground)

            FamilyActivityPicker(selection: $selection)
                .onChange(of: selection) { newValue in
                    manager.savedSelection = newValue
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(WakyTheme.background)
        .navigationTitle("Choose apps")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let saved = manager.savedSelection {
                selection = saved
            }
        }
    }
}

#Preview {
    NavigationView {
        AppBlockSettingsView()
    }
}
