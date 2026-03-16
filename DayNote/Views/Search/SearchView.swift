import SwiftUI
import SwiftData

struct SearchView: View {
    @Query private var allNotes: [DailyNote]
    @State private var searchText = ""
    @State private var searchResults: [SearchResult] = []

    var body: some View {
        NavigationStack {
            List {
                if searchText.isEmpty {
                    ContentUnavailableView(
                        "搜索笔记",
                        systemImage: "magnifyingglass",
                        description: Text("输入关键词搜索所有笔记内容")
                    )
                } else if searchResults.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                } else {
                    ForEach(searchResults) { result in
                        NavigationLink {
                            DailyNoteDetailView(dailyNote: result.dailyNote)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(result.dailyNote.displayDate)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(result.entry.content)
                                    .lineLimit(2)
                                    .font(.body)
                                Text(result.entry.timeString)
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }
            }
            .navigationTitle("搜索")
            .searchable(text: $searchText, prompt: "搜索笔记...")
            .onChange(of: searchText) {
                performSearch()
            }
        }
    }

    private func performSearch() {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else {
            searchResults = []
            return
        }

        let keyword = searchText.lowercased()
        var results: [SearchResult] = []

        for note in allNotes {
            for entry in note.entries {
                if entry.content.lowercased().contains(keyword) {
                    results.append(SearchResult(dailyNote: note, entry: entry))
                }
            }
        }

        searchResults = results.sorted { $0.entry.createdAt > $1.entry.createdAt }
    }
}

struct SearchResult: Identifiable {
    let id = UUID()
    let dailyNote: DailyNote
    let entry: NoteEntry
}
