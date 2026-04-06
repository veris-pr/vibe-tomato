import Foundation

struct BreakRecord: Codable, Identifiable {
    let id: UUID
    let date: Date
    let tracked: Bool

    init(date: Date, tracked: Bool) {
        self.id = UUID()
        self.date = date
        self.tracked = tracked
    }
}

struct DayStat: Identifiable {
    let id = UUID()
    let label: String
    let date: Date
    let tracked: Int
    let missed: Int
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

    func recordBreak(tracked: Bool, date: Date) {
        let record = BreakRecord(date: date, tracked: tracked)
        records.append(record)
        saveRecords()
    }

    // MARK: - Stats Queries

    func todayStats() -> [DayStat] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let todayRecords = records.filter { calendar.isDate($0.date, inSameDayAs: today) }
        let tracked = todayRecords.filter(\.tracked).count
        let missed = todayRecords.filter { !$0.tracked }.count
        return [DayStat(label: "Today", date: today, tracked: tracked, missed: missed)]
    }

    func weekStats() -> [DayStat] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return (0..<7).reversed().map { daysAgo in
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) else {
                return DayStat(label: "", date: today, tracked: 0, missed: 0)
            }
            let dayRecords = records.filter { calendar.isDate($0.date, inSameDayAs: date) }
            let tracked = dayRecords.filter(\.tracked).count
            let missed = dayRecords.filter { !$0.tracked }.count

            let formatter = DateFormatter()
            formatter.dateFormat = "EEE"
            let label = formatter.string(from: date)

            return DayStat(label: label, date: date, tracked: tracked, missed: missed)
        }
    }

    func monthStats() -> [DayStat] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Group into 4 weeks
        return (0..<4).reversed().map { weeksAgo in
            let weekEnd = calendar.date(byAdding: .day, value: -(weeksAgo * 7), to: today)!
            let weekStart = calendar.date(byAdding: .day, value: -6, to: weekEnd)!

            let weekRecords = records.filter { record in
                let recordDate = calendar.startOfDay(for: record.date)
                return recordDate >= weekStart && recordDate <= weekEnd
            }

            let tracked = weekRecords.filter(\.tracked).count
            let missed = weekRecords.filter { !$0.tracked }.count

            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            let label = "W\(4 - weeksAgo)"

            return DayStat(label: label, date: weekStart, tracked: tracked, missed: missed)
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
