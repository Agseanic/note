import Foundation
import SwiftData

@Model
class NoteEntry {
    var id: UUID = UUID()
    var content: String = ""
    var isReminder: Bool = false
    var isCompleted: Bool = false
    var reminderTime: Date?
    var shouldContinueRemind: Bool = false
    var createdAt: Date = Date()
    var dailyNote: DailyNote?

    init(content: String, isReminder: Bool = false, reminderTime: Date? = nil) {
        self.content = content
        self.isReminder = isReminder
        self.reminderTime = reminderTime
    }

    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: createdAt)
    }
}
