import Foundation
import Combine

final class AppSettings: ObservableObject {
    enum Limits {
        static let workMinutes = 1...120
        static let shortBreakMinutes = 1...30
        static let longBreakMinutes = 1...60
        static let sessionsBeforeLongBreak = 2...8
    }

    private enum Keys {
        static let workMinutes = "workMinutes"
        static let shortBreakMinutes = "shortBreakMinutes"
        static let longBreakMinutes = "longBreakMinutes"
        static let sessionsBeforeLongBreak = "sessionsBeforeLongBreak"
    }

    @Published private(set) var workMinutes: Int

    @Published private(set) var shortBreakMinutes: Int

    @Published private(set) var longBreakMinutes: Int

    @Published private(set) var sessionsBeforeLongBreak: Int

    var workSeconds: Int { workMinutes * 60 }
    var shortBreakSeconds: Int { shortBreakMinutes * 60 }
    var longBreakSeconds: Int { longBreakMinutes * 60 }

    init() {
        let defaults = UserDefaults.standard

        if defaults.object(forKey: Keys.workMinutes) == nil {
            defaults.set(25, forKey: Keys.workMinutes)
        }
        if defaults.object(forKey: Keys.shortBreakMinutes) == nil {
            defaults.set(5, forKey: Keys.shortBreakMinutes)
        }
        if defaults.object(forKey: Keys.longBreakMinutes) == nil {
            defaults.set(15, forKey: Keys.longBreakMinutes)
        }
        if defaults.object(forKey: Keys.sessionsBeforeLongBreak) == nil {
            defaults.set(4, forKey: Keys.sessionsBeforeLongBreak)
        }

        self.workMinutes = Self.clamp(defaults.integer(forKey: Keys.workMinutes), to: Limits.workMinutes)
        self.shortBreakMinutes = Self.clamp(defaults.integer(forKey: Keys.shortBreakMinutes), to: Limits.shortBreakMinutes)
        self.longBreakMinutes = Self.clamp(defaults.integer(forKey: Keys.longBreakMinutes), to: Limits.longBreakMinutes)
        self.sessionsBeforeLongBreak = Self.clamp(defaults.integer(forKey: Keys.sessionsBeforeLongBreak), to: Limits.sessionsBeforeLongBreak)

        defaults.set(workMinutes, forKey: Keys.workMinutes)
        defaults.set(shortBreakMinutes, forKey: Keys.shortBreakMinutes)
        defaults.set(longBreakMinutes, forKey: Keys.longBreakMinutes)
        defaults.set(sessionsBeforeLongBreak, forKey: Keys.sessionsBeforeLongBreak)
    }

    func setWorkMinutes(_ value: Int) {
        workMinutes = Self.clamp(value, to: Limits.workMinutes)
        UserDefaults.standard.set(workMinutes, forKey: Keys.workMinutes)
    }

    func setShortBreakMinutes(_ value: Int) {
        shortBreakMinutes = Self.clamp(value, to: Limits.shortBreakMinutes)
        UserDefaults.standard.set(shortBreakMinutes, forKey: Keys.shortBreakMinutes)
    }

    func setLongBreakMinutes(_ value: Int) {
        longBreakMinutes = Self.clamp(value, to: Limits.longBreakMinutes)
        UserDefaults.standard.set(longBreakMinutes, forKey: Keys.longBreakMinutes)
    }

    func setSessionsBeforeLongBreak(_ value: Int) {
        sessionsBeforeLongBreak = Self.clamp(value, to: Limits.sessionsBeforeLongBreak)
        UserDefaults.standard.set(sessionsBeforeLongBreak, forKey: Keys.sessionsBeforeLongBreak)
    }

    private static func clamp(_ value: Int, to range: ClosedRange<Int>) -> Int {
        min(max(value, range.lowerBound), range.upperBound)
    }
}
