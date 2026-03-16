import Foundation
import SwiftData

class NoteManager {
    static let shared = NoteManager()

    func getOrCreateTodayNote(context: ModelContext) -> DailyNote {
        let todayStr = Self.todayDateString()

        var descriptor = FetchDescriptor<DailyNote>()
        if let allNotes = try? context.fetch(descriptor) {
            if let existing = allNotes.first(where: { $0.date == todayStr }) {
                return existing
            }
        }

        let note = DailyNote(date: todayStr)
        context.insert(note)
        try? context.save()
        return note
    }

    func deleteEntry(_ entry: NoteEntry, context: ModelContext) {
        if let note = entry.dailyNote {
            note.entries.removeAll { $0.entryID == entry.entryID }
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
