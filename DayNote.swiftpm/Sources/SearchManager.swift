import Foundation
import SwiftData

class SearchManager {
    static let shared = SearchManager()

    func search(keyword: String, in context: ModelContext) -> [(DailyNote, NoteEntry)] {
        guard !keyword.trimmingCharacters(in: .whitespaces).isEmpty else { return [] }

        let descriptor = FetchDescriptor<NoteEntry>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        guard let entries = try? context.fetch(descriptor) else { return [] }

        let lowered = keyword.lowercased()
        return entries
            .filter { $0.content.lowercased().contains(lowered) }
            .compactMap { entry in
                guard let note = entry.dailyNote else { return nil }
                return (note, entry)
            }
    }
}
