import Foundation
import SwiftData

@Observable
class NoteManager {
    static let shared = NoteManager()

    func getOrCreateTodayNote(context: ModelContext) -> DailyNote {
        let todayStr = Self.todayDateString()
        let descriptor = FetchDescriptor<DailyNote>(predicate: #Predicate { $0.date == todayStr })

        if let existing = try? context.fetch(descriptor).first {
            return existing
        }

        let note = DailyNote(date: todayStr)
        context.insert(note)
        try? context.save()
        return note
    }

    func addEntry(to note: DailyNote, content: String, isReminder: Bool = false, reminderTime: Date? = nil, context: ModelContext) {
        let entry = NoteEntry(content: content, isReminder: isReminder, reminderTime: reminderTime)
        entry.dailyNote = note
        note.entries.append(entry)
        try? context.save()
    }

    func deleteEntry(_ entry: NoteEntry, context: ModelContext) {
        if let note = entry.dailyNote {
            note.entries.removeAll { $0.id == entry.id }
        }
        context.delete(entry)
        try? context.save()
    }

    static func todayDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
