import SwiftUI

@main
struct WakyApp: App {
    init() {
        // Reshow onboarding every time the app is run
        UserDefaults.standard.set(0, forKey: "waky_onboarding_step")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
