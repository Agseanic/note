import Foundation

class SummaryService {
    static let shared = SummaryService()

    func generateSummary(for note: DailyNote) -> String {
        let entries = note.sortedEntries
        return LocalSummarizer.generateSummary(from: entries)
    }
}
