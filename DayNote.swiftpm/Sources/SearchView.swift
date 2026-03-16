import SwiftUI
import SwiftData

struct SearchView: View {
    @Query private var allNotes: [DailyNote]
    @State private var searchText = ""
    @State private var searchResults: [SearchResult] = []
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if searchText.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass.circle.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(.blue.opacity(0.6))
                            .symbolRenderingMode(.hierarchical)
                        Text("搜索笔记")
                            .font(.system(.title3, design: .rounded, weight: .semibold))
                            .foregroundStyle(.primary)
                        Text("输入关键词搜索所有笔记内容")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    .padding(32)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color(uiColor: .systemBackground))
                            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
                    )
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if searchResults.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 56))
                            .foregroundStyle(.secondary)
                            .symbolRenderingMode(.hierarchical)
                        Text("没有找到相关笔记")
                            .font(.system(.title3, design: .rounded, weight: .semibold))
                            .foregroundStyle(.primary)
                        Text("尝试使用其他关键词搜索")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    .padding(32)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color(uiColor: .systemBackground))
                            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
                    )
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            Text("找到 \(searchResults.count) 条结果")
                                .font(.system(.caption, design: .rounded, weight: .medium))
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 4)
                                .padding(.top, 8)

                            ForEach(searchResults) { result in
                                NavigationLink {
                                    DailyNoteDetailView(dailyNote: result.dailyNote)
                                } label: {
                                    VStack(alignment: .leading, spacing: 6) {
                                        HStack {
                                            Text(result.dailyNote.displayDate)
                                                .font(.system(.caption, design: .rounded, weight: .semibold))
                                                .foregroundStyle(.blue)
                                            Spacer()
                                            Text(result.entry.timeString)
                                                .font(.system(.caption2, design: .rounded))
                                                .foregroundStyle(.tertiary)
                                        }
                                        Text(result.entry.content)
                                            .font(.system(.body, design: .rounded))
                                            .foregroundStyle(.primary)
                                            .lineLimit(2)
                                            .multilineTextAlignment(.leading)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                                            .fill(Color(uiColor: .systemBackground))
                                            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("搜索")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "搜索笔记...")
            .onChange(of: searchText) {
                performSearch()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") { dismiss() }
                }
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
