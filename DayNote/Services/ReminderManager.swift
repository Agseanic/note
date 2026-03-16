import Foundation
import SwiftData

class ReminderManager {
    static let shared = ReminderManager()

    func getPendingReminders(context: ModelContext) -> [NoteEntry] {
        let descriptor = FetchDescriptor<NoteEntry>(
            predicate: #Predicate<NoteEntry> { entry in
                entry.isReminder && !entry.isCompleted
            },
            sortBy: [SortDescriptor(\.reminderTime)]
        )

        return (try? context.fetch(descriptor)) ?? []
    }

    func toggleCompletion(_ entry: NoteEntry, context: ModelContext) {
        entry.isCompleted.toggle()
        if entry.isCompleted {
            NotificationService.shared.cancelReminder(for: entry.id.uuidString)
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
