import Foundation
import SwiftData

class ReminderManager {
    static let shared = ReminderManager()

    func getPendingReminders(context: ModelContext) -> [NoteEntry] {
        let descriptor = FetchDescriptor<NoteEntry>(
            sortBy: [SortDescriptor(\.reminderTime)]
        )

        guard let entries = try? context.fetch(descriptor) else { return [] }
        return entries.filter { $0.isReminder && !$0.isCompleted }
    }

    func toggleCompletion(_ entry: NoteEntry, context: ModelContext) {
        entry.isCompleted.toggle()
        if entry.isCompleted {
            NotificationService.shared.cancelReminder(for: entry.entryID.uuidString)
        }
        try? context.save()
    }

    func postponeReminder(_ entry: NoteEntry, byMinutes minutes: Int, context: ModelContext) {
        let newTime = Date().addingTimeInterval(TimeInterval(minutes * 60))
        entry.reminderTime = newTime
        NotificationService.shared.scheduleReminder(entry: entry, at: newTime)
        try? context.save()
    }
}
