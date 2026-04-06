import SwiftUI

@MainActor
final class AppState: ObservableObject {
    let settings: AppSettings
    let sessionStore: SessionStore
    let timer: PomodoroTimer

    init() {
        let settings = AppSettings()
        let sessionStore = SessionStore()
        self.settings = settings
        self.sessionStore = sessionStore
        self.timer = PomodoroTimer(settings: settings, sessionStore: sessionStore)
    }
}

@main
struct TomatoApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        MenuBarExtra {
            MenuContentView(
                timer: appState.timer,
                settings: appState.settings,
                sessionStore: appState.sessionStore
            )
        } label: {
            MenuBarIcon(timer: appState.timer)
        }
        .menuBarExtraStyle(.window)
    }
}

struct MenuBarIcon: View {
    @ObservedObject var timer: PomodoroTimer

    var body: some View {
        Image(systemName: "circle.fill")
            .symbolRenderingMode(.palette)
            .foregroundStyle(timer.menuBarColor)
            .font(.system(size: 12))
    }
}
