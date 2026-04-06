import Foundation
import SwiftUI

enum TimerState: String, Codable, Sendable {
    case working
    case onBreak
    case paused
}

@MainActor
final class PomodoroTimer: ObservableObject {
    @Published var state: TimerState = .working
    @Published var remainingSeconds: Int = 0
    @Published var completedWorkSessions: Int = 0

    /// Whether the user acknowledged the current break by clicking the icon
    @Published var breakAcknowledged: Bool = false

    private var timer: Timer?
    private let settings: AppSettings
    private let sessionStore: SessionStore

    /// Remembers what state we were in before pausing
    private var stateBeforePause: TimerState = .working

    var isLongBreak: Bool {
        completedWorkSessions > 0 && completedWorkSessions % settings.sessionsBeforeLongBreak == 0
    }

    var currentBreakDuration: Int {
        isLongBreak ? settings.longBreakSeconds : settings.shortBreakSeconds
    }

    var progress: Double {
        let total: Int
        switch state {
        case .paused:
            switch stateBeforePause {
            case .working: total = settings.workSeconds
            case .onBreak: total = currentBreakDuration
            case .paused: return 0
            }
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
        case .working:
            return .primary
        case .onBreak:
            return .orange
        case .paused:
            return .gray
        }
    }

    init(settings: AppSettings, sessionStore: SessionStore) {
        self.settings = settings
        self.sessionStore = sessionStore
        // Always-on: start working immediately
        remainingSeconds = settings.workSeconds
        startCountdown()
    }

    func pause() {
        guard state != .paused else { return }
        // If pausing during a break, record it as a paused break
        if state == .onBreak && !breakAcknowledged {
            sessionStore.recordBreak(outcome: .paused, date: Date())
            breakAcknowledged = true
        }
        stateBeforePause = state
        timer?.invalidate()
        timer = nil
        state = .paused
    }

    func resume() {
        guard state == .paused else { return }
        // Resume into a fresh work session (break was already recorded if applicable)
        if stateBeforePause == .onBreak {
            startWork()
        } else {
            state = stateBeforePause
            startCountdown()
        }
    }

    func acknowledgeBreak() {
        guard state == .onBreak, !breakAcknowledged else { return }
        breakAcknowledged = true
        sessionStore.recordBreak(outcome: .tracked, date: Date())
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
        startWork()
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
                    sessionStore.recordBreak(outcome: .missed, date: Date())
                }
                endBreak()
            case .paused:
                break
            }
        }
    }
}
