import Foundation
import SwiftData

class SearchManager {
    static let shared = SearchManager()

    func search(keyword: String, in context: ModelContext) -> [(DailyNote, NoteEntry)] {
        guard !keyword.trimmingCharacters(in: .whitespaces).isEmpty else { return [] }

        let descriptor = FetchDescriptor<NoteEntry>(
            predicate: #Predicate<NoteEntry> { entry in
                entry.content.localizedStandardContains(keyword)
            },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        guard let entries = try? context.fetch(descriptor) else { return [] }

        return entries.compactMap { entry in
            guard let note = entry.dailyNote else { return nil }
            return (note, entry)
        }
    }
}
