import Foundation
import FamilyControls
import ManagedSettings
import SwiftUI

/// Manages Screen Time authorization, app selection, and shielding (blocking) of apps like TikTok, Instagram.
/// Requires Family Controls capability and runs on a physical device (not simulator).
final class AppBlockManager: ObservableObject {
    static let shared = AppBlockManager()

    private let store = ManagedSettingsStore()
    private let selectionKey = "waky_blocked_apps_selection"
    private let blockingEnabledKey = "waky_app_blocking_enabled"

    @Published private(set) var authorizationStatus: AuthorizationStatus = .notDetermined
    @Published var isBlockingEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isBlockingEnabled, forKey: blockingEnabledKey)
            applyShield()
        }
    }

    /// Persisted selection from FamilyActivityPicker (encoded).
    var savedSelection: FamilyActivitySelection? {
        get {
            guard let data = UserDefaults.standard.data(forKey: selectionKey),
                  let selection = try? PropertyListDecoder().decode(FamilyActivitySelection.self, from: data) else { return nil }
            return selection
        }
        set {
            if let selection = newValue,
               let data = try? PropertyListEncoder().encode(selection) {
                UserDefaults.standard.set(data, forKey: selectionKey)
            } else {
                UserDefaults.standard.removeObject(forKey: selectionKey)
            }
            applyShield()
        }
    }

    var hasSelectedApps: Bool {
        savedSelection.map { !$0.applicationTokens.isEmpty || !$0.categoryTokens.isEmpty } ?? false
    }

    private init() {
        self.isBlockingEnabled = UserDefaults.standard.bool(forKey: blockingEnabledKey)
        Task { @MainActor in await updateAuthorizationStatus() }
    }

    @MainActor
    @available(iOS 16.0, *)
    func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            await updateAuthorizationStatus()
        } catch {
            await updateAuthorizationStatus()
        }
    }

    @MainActor
    func updateAuthorizationStatus() async {
        authorizationStatus = AuthorizationCenter.shared.authorizationStatus
    }

    /// Apply or clear shield based on isBlockingEnabled and saved selection.
    /// Supports both individual apps (applicationTokens) and categories (categoryTokens).
    func applyShield() {
        let hasApps = savedSelection.map { !$0.applicationTokens.isEmpty } ?? false
        let hasCategories = savedSelection.map { !$0.categoryTokens.isEmpty } ?? false
        guard isBlockingEnabled, let selection = savedSelection, hasApps || hasCategories else {
            store.shield.applications = nil
            store.shield.applicationCategories = .none
            return
        }
        applyShield(using: selection)
    }

    /// Apply shield using the given selection directly (avoids relying on encode/decode round-trip).
    /// Use this when the user just selected so the in-memory selection is applied immediately.
    func applyShield(using selection: FamilyActivitySelection) {
        store.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
        if !selection.categoryTokens.isEmpty {
            store.shield.applicationCategories = .specific(selection.categoryTokens)
        } else {
            store.shield.applicationCategories = .none
        }
    }
}
