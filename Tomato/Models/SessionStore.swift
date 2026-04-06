import Foundation

enum BreakOutcome: String, Codable, Sendable {
    case tracked  // user clicked the orange dot
    case missed   // break timer expired without acknowledgment
    case paused   // user paused the timer during a break
}

struct BreakRecord: Codable, Identifiable {
    let id: UUID
    let date: Date
    let outcome: BreakOutcome

    init(date: Date, outcome: BreakOutcome) {
        self.id = UUID()
        self.date = date
        self.outcome = outcome
    }
}

struct DayStat: Identifiable {
    let id = UUID()
    let label: String
    let date: Date
    let tracked: Int
    let missed: Int
    let paused: Int
}

final class SessionStore: ObservableObject {
    @Published private(set) var records: [BreakRecord] = []

    private let fileURL: URL

    init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDir = appSupport.appendingPathComponent("Tomato", isDirectory: true)

        if !FileManager.default.fileExists(atPath: appDir.path) {
            try? FileManager.default.createDirectory(at: appDir, withIntermediateDirectories: true)
        }

        self.fileURL = appDir.appendingPathComponent("sessions.json")
        loadRecords()
    }

    func recordBreak(outcome: BreakOutcome, date: Date) {
        let record = BreakRecord(date: date, outcome: outcome)
        records.append(record)
        saveRecords()
    }

    // MARK: - Stats Queries

    func todayStats() -> [DayStat] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let todayRecords = records.filter { calendar.isDate($0.date, inSameDayAs: today) }
        return [DayStat(
            label: "Today", date: today,
            tracked: todayRecords.filter { $0.outcome == .tracked }.count,
            missed: todayRecords.filter { $0.outcome == .missed }.count,
            paused: todayRecords.filter { $0.outcome == .paused }.count
        )]
    }

    func weekStats() -> [DayStat] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return (0..<7).reversed().map { daysAgo in
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) else {
                return DayStat(label: "", date: today, tracked: 0, missed: 0, paused: 0)
            }
            let dayRecords = records.filter { calendar.isDate($0.date, inSameDayAs: date) }

            let formatter = DateFormatter()
            formatter.dateFormat = "EEE"

            return DayStat(
                label: formatter.string(from: date), date: date,
                tracked: dayRecords.filter { $0.outcome == .tracked }.count,
                missed: dayRecords.filter { $0.outcome == .missed }.count,
                paused: dayRecords.filter { $0.outcome == .paused }.count
            )
        }
    }

    func monthStats() -> [DayStat] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return (0..<4).reversed().map { weeksAgo in
            let weekEnd = calendar.date(byAdding: .day, value: -(weeksAgo * 7), to: today)!
            let weekStart = calendar.date(byAdding: .day, value: -6, to: weekEnd)!

            let weekRecords = records.filter { record in
                let recordDate = calendar.startOfDay(for: record.date)
                return recordDate >= weekStart && recordDate <= weekEnd
            }

            return DayStat(
                label: "W\(4 - weeksAgo)", date: weekStart,
                tracked: weekRecords.filter { $0.outcome == .tracked }.count,
                missed: weekRecords.filter { $0.outcome == .missed }.count,
                paused: weekRecords.filter { $0.outcome == .paused }.count
            )
        }
    }

    // MARK: - Persistence

    private func loadRecords() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        do {
            let data = try Data(contentsOf: fileURL)
            records = try JSONDecoder().decode([BreakRecord].self, from: data)
        } catch {
            print("Failed to load session records: \(error)")
            records = []
        }
    }

    private func saveRecords() {
        do {
            let data = try JSONEncoder().encode(records)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Failed to save session records: \(error)")
        }
    }
}
