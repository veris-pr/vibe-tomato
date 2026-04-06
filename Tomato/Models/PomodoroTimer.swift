import Foundation
import SwiftUI

enum TimerState: String, Codable, Sendable {
    case idle
    case working
    case onBreak
}

@MainActor
final class PomodoroTimer: ObservableObject {
    @Published var state: TimerState = .idle
    @Published var remainingSeconds: Int = 0
    @Published var completedWorkSessions: Int = 0

    /// Whether the user acknowledged the current break by clicking the icon
    @Published var breakAcknowledged: Bool = false

    private var timer: Timer?
    private let settings: AppSettings
    private let sessionStore: SessionStore

    var isLongBreak: Bool {
        completedWorkSessions > 0 && completedWorkSessions % settings.sessionsBeforeLongBreak == 0
    }

    var currentBreakDuration: Int {
        isLongBreak ? settings.longBreakSeconds : settings.shortBreakSeconds
    }

    var progress: Double {
        let total: Int
        switch state {
        case .idle:
            return 0
        case .working:
            total = settings.workSeconds
        case .onBreak:
            total = currentBreakDuration
        }
        guard total > 0 else { return 0 }
        return 1.0 - (Double(remainingSeconds) / Double(total))
    }

    var formattedTime: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var menuBarColor: Color {
        switch state {
        case .idle:
            return .gray
        case .working:
            return .primary
        case .onBreak:
            return .orange
        }
    }

    init(settings: AppSettings, sessionStore: SessionStore) {
        self.settings = settings
        self.sessionStore = sessionStore
    }

    func start() {
        startWork()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        state = .idle
        remainingSeconds = 0
        breakAcknowledged = false
    }

    func acknowledgeBreak() {
        guard state == .onBreak, !breakAcknowledged else { return }
        breakAcknowledged = true
        sessionStore.recordBreak(tracked: true, date: Date())
        endBreak()
    }

    func menuDidOpen() {
        if state == .onBreak && !breakAcknowledged {
            acknowledgeBreak()
        }
    }

    private func startWork() {
        timer?.invalidate()
        state = .working
        remainingSeconds = settings.workSeconds
        breakAcknowledged = false
        startCountdown()
    }

    private func startBreak() {
        state = .onBreak
        remainingSeconds = currentBreakDuration
        breakAcknowledged = false
        startCountdown()
    }

    private func endBreak() {
        timer?.invalidate()
        timer = nil
        if settings.autoStartWork {
            startWork()
        } else {
            state = .idle
            remainingSeconds = 0
        }
    }

    private func startCountdown() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }

    private func tick() {
        guard remainingSeconds > 0 else { return }
        remainingSeconds -= 1

        if remainingSeconds <= 0 {
            timer?.invalidate()
            timer = nil

            switch state {
            case .working:
                completedWorkSessions += 1
                startBreak()
            case .onBreak:
                if !breakAcknowledged {
                    sessionStore.recordBreak(tracked: false, date: Date())
                }
                endBreak()
            case .idle:
                break
            }
        }
    }
}
