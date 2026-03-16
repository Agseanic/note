import Foundation
import SwiftData

@Model
class DailyNote {
    @Attribute(.unique) var date: String  // "2026-03-10"
    @Relationship(deleteRule: .cascade, inverse: \NoteEntry.dailyNote)
    var entries: [NoteEntry] = []
    var summary: String?
    var createdAt: Date = Date()

    init(date: String) {
        self.date = date
    }

    var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let d = formatter.date(from: date) else { return date }
        formatter.dateFormat = "M月d日 EEEE"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: d)
    }

    var sortedEntries: [NoteEntry] {
        entries.sorted { $0.createdAt < $1.createdAt }
    }
}
