import SwiftUI
import Inject

/// Bottom tab navigation: Home (bedtime selection) and Session tracking (history + average).
struct MainTabView: View {
    @ObserveInjection var inject
    @ObservedObject var sessionStore: SessionStore
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            WakeTimeView(sessionStore: sessionStore)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            SessionHistoryView(sessionStore: sessionStore)
                .tabItem {
                    Label("Sessions", systemImage: "list.bullet.clipboard.fill")
                }
                .tag(1)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(2)
        }
        .tint(WakyTheme.accent)
        .enableInjection()
    }
}

#Preview {
    MainTabView(sessionStore: SessionStore())
}
