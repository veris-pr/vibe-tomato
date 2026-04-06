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
        .onAppear {
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
                if timer.state != .idle {
                    Text("Session \(timer.completedWorkSessions + (timer.state == .working ? 1 : 0))")
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                }
            }

            Text(timer.state == .idle ? "--:--" : timer.formattedTime)
                .font(.system(size: 40, weight: .light, design: .monospaced))
                .foregroundStyle(timer.state == .onBreak ? .orange : .primary)

            if timer.state != .idle {
                ProgressView(value: timer.progress)
                    .tint(timer.state == .onBreak ? .orange : .accentColor)
            }
        }
    }

    private var stateLabel: String {
        switch timer.state {
        case .idle: return "IDLE"
        case .working: return "FOCUS"
        case .onBreak: return "BREAK"
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
                if timer.state == .idle {
                    Button(action: { timer.start() }) {
                        Label("Start", systemImage: "play.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.regular)
                } else {
                    Button(action: { timer.stop() }) {
                        Label("Stop", systemImage: "stop.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.regular)
                }

                Button(action: { showSettings.toggle() }) {
                    Label("Settings", systemImage: "gear")
                }
                .buttonStyle(.bordered)
                .controlSize(.regular)
                .popover(isPresented: $showSettings, arrowEdge: .trailing) {
                    SettingsView(settings: settings)
                }
            }

            Button("Quit Tomato") {
                NSApplication.shared.terminate(nil)
            }
            .font(.system(size: 11))
            .foregroundStyle(.secondary)
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
    }
}
