import AppKit
import Foundation
import SwiftUI

enum TimerState: String, Codable, Sendable {
    case working
    case onBreak
    case paused
}

@MainActor
final class PomodoroTimer: ObservableObject {
    private enum Keys {
        static let snapshot = "timerSnapshot"
    }

    private struct TimerSnapshot: Codable {
        let state: TimerState
        let remainingSeconds: Int
        let completedWorkSessions: Int
        let breakAcknowledged: Bool
        let stateBeforePause: TimerState
        let phaseEndDate: Date?
    }

    @Published var state: TimerState = .working
    @Published var remainingSeconds: Int = 0
    @Published var completedWorkSessions: Int = 0

    /// Whether the user acknowledged the current break by clicking the icon
    @Published var breakAcknowledged: Bool = false

    private var timer: Timer?
    private let settings: AppSettings
    private let sessionStore: SessionStore
    private var phaseEndDate: Date?
    private var wakeObserver: NSObjectProtocol?
    private var activationObserver: NSObjectProtocol?

    /// Remembers what state we were in before pausing
    private var stateBeforePause: TimerState = .working

    var isLongBreak: Bool {
        completedWorkSessions > 0 && completedWorkSessions % max(settings.sessionsBeforeLongBreak, 1) == 0
    }

    var currentBreakDuration: Int {
        isLongBreak ? settings.longBreakSeconds : settings.shortBreakSeconds
    }

    var isAwaitingBreakAcknowledgment: Bool {
        state == .onBreak && !breakAcknowledged
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
            return .secondary
        }
    }

    init(settings: AppSettings, sessionStore: SessionStore) {
        self.settings = settings
        self.sessionStore = sessionStore
        restoreOrStart()
        registerForLifecycleNotifications()
    }

    func pause() {
        guard state != .paused else { return }
        synchronizeToCurrentTime()
        if state == .onBreak && !breakAcknowledged {
            sessionStore.recordBreak(outcome: .paused, date: Date())
            breakAcknowledged = true
        }
        stateBeforePause = state
        timer?.invalidate()
        timer = nil
        phaseEndDate = nil
        state = .paused
        saveSnapshot()
    }

    func resume() {
        guard state == .paused else { return }
        if stateBeforePause == .onBreak {
            startWork()
        } else {
            state = stateBeforePause
            phaseEndDate = Date().addingTimeInterval(TimeInterval(remainingSeconds))
            startCountdown()
            saveSnapshot()
        }
    }

    func acknowledgeBreak() {
        guard state == .onBreak, !breakAcknowledged else { return }
        breakAcknowledged = true
        sessionStore.recordBreak(outcome: .tracked, date: Date())
        endBreak()
    }

    func skipBreak() {
        guard state == .onBreak, !breakAcknowledged else { return }
        breakAcknowledged = true
        sessionStore.recordBreak(outcome: .skipped, date: Date())
        endBreak()
    }

    func completeBreakAndReset() {
        if state == .onBreak {
            breakAcknowledged = true
        }
        sessionStore.recordBreak(outcome: .tracked, date: Date())
        resetToWorkTimer()
    }

    func skipBreakAndReset() {
        if state == .onBreak {
            breakAcknowledged = true
        }
        sessionStore.recordBreak(outcome: .skipped, date: Date())
        resetToWorkTimer()
    }

    func resetToWorkTimer() {
        timer?.invalidate()
        timer = nil
        startWork()
    }

    private func startWork() {
        state = .working
        remainingSeconds = settings.workSeconds
        breakAcknowledged = false
        phaseEndDate = Date().addingTimeInterval(TimeInterval(settings.workSeconds))
        startCountdown()
        saveSnapshot()
    }

    private func startBreak() {
        state = .onBreak
        remainingSeconds = currentBreakDuration
        breakAcknowledged = false
        phaseEndDate = Date().addingTimeInterval(TimeInterval(currentBreakDuration))
        startCountdown()
        saveSnapshot()
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
        timer?.tolerance = 0.2
    }

    private func tick() {
        synchronizeToCurrentTime()
    }

    private func restoreOrStart() {
        guard
            let data = UserDefaults.standard.data(forKey: Keys.snapshot),
            let snapshot = try? JSONDecoder().decode(TimerSnapshot.self, from: data)
        else {
            startWork()
            return
        }

        state = snapshot.state
        remainingSeconds = max(snapshot.remainingSeconds, 0)
        completedWorkSessions = max(snapshot.completedWorkSessions, 0)
        breakAcknowledged = snapshot.breakAcknowledged
        stateBeforePause = snapshot.stateBeforePause
        phaseEndDate = snapshot.phaseEndDate

        if state == .paused {
            saveSnapshot()
            return
        }

        guard phaseEndDate != nil else {
            startWork()
            return
        }

        synchronizeToCurrentTime()
        startCountdown()
    }

    private func synchronizeToCurrentTime(now: Date = Date()) {
        guard state != .paused else { return }
        guard var currentEndDate = phaseEndDate else {
            startWork()
            return
        }

        while currentEndDate <= now {
            switch state {
            case .working:
                completedWorkSessions += 1
                state = .onBreak
                breakAcknowledged = false
                let breakDuration = currentBreakDuration
                remainingSeconds = breakDuration
                currentEndDate = currentEndDate.addingTimeInterval(TimeInterval(breakDuration))
            case .onBreak:
                if !breakAcknowledged {
                    sessionStore.recordBreak(outcome: .missed, date: currentEndDate)
                }
                state = .working
                breakAcknowledged = false
                remainingSeconds = settings.workSeconds
                currentEndDate = currentEndDate.addingTimeInterval(TimeInterval(settings.workSeconds))
            case .paused:
                return
            }
        }

        phaseEndDate = currentEndDate
        remainingSeconds = max(Int(ceil(currentEndDate.timeIntervalSince(now))), 0)
        saveSnapshot()
    }

    private func saveSnapshot() {
        let snapshot = TimerSnapshot(
            state: state,
            remainingSeconds: remainingSeconds,
            completedWorkSessions: completedWorkSessions,
            breakAcknowledged: breakAcknowledged,
            stateBeforePause: stateBeforePause,
            phaseEndDate: phaseEndDate
        )

        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        UserDefaults.standard.set(data, forKey: Keys.snapshot)
    }

    private func registerForLifecycleNotifications() {
        wakeObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.synchronizeToCurrentTime()
            }
        }

        activationObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.synchronizeToCurrentTime()
            }
        }
    }
}
