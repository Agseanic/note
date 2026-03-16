import SwiftUI
import SwiftData

struct BrowseView: View {
    @Query(sort: \DailyNote.date, order: .reverse) private var notes: [DailyNote]
    @State private var selectedDate = Date()
    @State private var selectedNote: DailyNote?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    DatePicker("选择日期", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .onChange(of: selectedDate) {
                            let dateStr = formatDate(selectedDate)
                            selectedNote = notes.first { $0.date == dateStr }
                        }
                }

                if let note = selectedNote {
                    Section("笔记 (\(note.entries.count) 条)") {
                        ForEach(note.sortedEntries) { entry in
                            BrowseEntryRow(entry: entry)
                        }
                    }

                    if let summary = note.summary, !summary.isEmpty {
                        Section("摘要") {
                            Text(summary)
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                    }
                } else {
                    Section {
                        ContentUnavailableView(
                            "该日期没有笔记",
                            systemImage: "calendar.badge.exclamationmark"
                        )
                    }
                }

                Section("近期笔记") {
                    ForEach(notes.prefix(20)) { note in
                        NavigationLink {
                            DailyNoteDetailView(dailyNote: note)
                        } label: {
                            HStack {
                                Text(note.displayDate)
                                Spacer()
                                Text("\(note.entries.count) 条")
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                            }
                        }
                    }
                }
            }
            .navigationTitle("浏览")
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

struct BrowseEntryRow: View {
    let entry: NoteEntry

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if entry.isReminder {
                Image(systemName: entry.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(entry.isCompleted ? .green : .orange)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.content)
                    .lineLimit(3)
                Text(entry.timeString)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct DailyNoteDetailView: View {
    let dailyNote: DailyNote

    var body: some View {
        List {
            ForEach(dailyNote.sortedEntries) { entry in
                ChatBubbleView(entry: entry)
                    .listRowSeparator(.hidden)
            }

            if let summary = dailyNote.summary, !summary.isEmpty {
                Section("摘要") {
                    Text(summary)
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle(dailyNote.displayDate)
    }
}
