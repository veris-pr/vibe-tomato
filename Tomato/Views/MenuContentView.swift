import SwiftUI

struct MenuContentView: View {
    @ObservedObject var timer: PomodoroTimer
    @ObservedObject var settings: AppSettings
    @ObservedObject var sessionStore: SessionStore
    @State private var showSettings = false

    var body: some View {
        VStack(spacing: 0) {
            timerSection
            Divider().padding(.vertical, 4)
            statsSection
            Divider().padding(.vertical, 4)
            controlsSection
        }
        .padding(12)
        .frame(width: 320)
        .task {
            // Defer to avoid layout recursion in MenuBarExtra
            try? await Task.sleep(for: .milliseconds(50))
            timer.menuDidOpen()
        }
    }

    // MARK: - Timer Section

    private var timerSection: some View {
        VStack(spacing: 8) {
            HStack {
                Text(stateLabel)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
                Spacer()
                Text("Session \(timer.completedWorkSessions + (timer.state == .working ? 1 : 0))")
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
            }

            Text(timer.formattedTime)
                .font(.system(size: 40, weight: .light, design: .monospaced))
                .foregroundStyle(timerColor)

            ProgressView(value: timer.progress)
                .tint(timerColor)
        }
    }

    private var stateLabel: String {
        switch timer.state {
        case .working: return "FOCUS"
        case .onBreak: return "BREAK"
        case .paused: return "PAUSED"
        }
    }

    private var timerColor: Color {
        switch timer.state {
        case .working: return .primary
        case .onBreak: return .orange
        case .paused: return .secondary
        }
    }

    // MARK: - Stats Section

    private var statsSection: some View {
        VStack(spacing: 12) {
            StatsChartView(title: "Today", stats: sessionStore.todayStats())
            StatsChartView(title: "This Week", stats: sessionStore.weekStats())
            StatsChartView(title: "This Month", stats: sessionStore.monthStats())
        }
    }

    // MARK: - Controls Section

    private var controlsSection: some View {
        VStack(spacing: 6) {
            HStack(spacing: 8) {
                Button(action: {
                    if timer.state == .paused { timer.resume() } else { timer.pause() }
                }) {
                    Label(
                        timer.state == .paused ? "Resume" : "Pause",
                        systemImage: timer.state == .paused ? "play.fill" : "pause.fill"
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.regular)

                Button(action: { showSettings.toggle() }) {
                    Label("Settings", systemImage: "gear")
                }
                .buttonStyle(.bordered)
                .controlSize(.regular)
                .popover(isPresented: $showSettings, arrowEdge: .trailing) {
                    SettingsView(settings: settings)
                }
            }

            QuitButton()
                .padding(.top, 4)
        }
    }
}

private struct QuitButton: View {
    @State private var isHovered = false

    var body: some View {
        Button(action: { NSApplication.shared.terminate(nil) }) {
            ZStack {
                Text("Quit Tomato")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .opacity(isHovered ? 0 : 1)

                SplatTomatoIcon()
                    .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    .foregroundStyle(.primary)
                    .frame(width: 18, height: 18)
                    .opacity(isHovered ? 1 : 0)
            }
            .frame(height: 18)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}
