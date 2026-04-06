import Foundation
import Combine

final class AppSettings: ObservableObject {
    private enum Keys {
        static let workMinutes = "workMinutes"
        static let shortBreakMinutes = "shortBreakMinutes"
        static let longBreakMinutes = "longBreakMinutes"
        static let sessionsBeforeLongBreak = "sessionsBeforeLongBreak"
    }

    @Published var workMinutes: Int {
        didSet { UserDefaults.standard.set(workMinutes, forKey: Keys.workMinutes) }
    }

    @Published var shortBreakMinutes: Int {
        didSet { UserDefaults.standard.set(shortBreakMinutes, forKey: Keys.shortBreakMinutes) }
    }

    @Published var longBreakMinutes: Int {
        didSet { UserDefaults.standard.set(longBreakMinutes, forKey: Keys.longBreakMinutes) }
    }

    @Published var sessionsBeforeLongBreak: Int {
        didSet { UserDefaults.standard.set(sessionsBeforeLongBreak, forKey: Keys.sessionsBeforeLongBreak) }
    }

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

        self.workMinutes = defaults.integer(forKey: Keys.workMinutes)
        self.shortBreakMinutes = defaults.integer(forKey: Keys.shortBreakMinutes)
        self.longBreakMinutes = defaults.integer(forKey: Keys.longBreakMinutes)
        self.sessionsBeforeLongBreak = defaults.integer(forKey: Keys.sessionsBeforeLongBreak)
    }
}
