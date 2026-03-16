import SwiftUI
import SwiftData

@main
struct DayNoteApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [DailyNote.self, NoteEntry.self])
    }
}
