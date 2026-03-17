import SwiftUI
import SwiftData

struct BrowseView: View {
    @Query(sort: \DailyNote.date, order: .reverse) private var notes: [DailyNote]
    @State private var selectedDate = Date()
    @State private var selectedDetailNote: DailyNote?
    @State private var showDetail = false

    private var selectedDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: selectedDate)
    }

    private var selectedNote: DailyNote? {
        notes.first { $0.date == selectedDateString }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // 标题放在ScrollView内部，消除边界线
                Text("浏览")
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.top, 12)
                    .padding(.bottom, 16)

                VStack(spacing: 20) {
                    DatePicker("选择日期", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .padding(.horizontal)
                        .environment(\.locale, Locale(identifier: "zh_CN"))
                        .tint(.blue)

                    if let note = selectedNote {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(note.displayDate)
                                    .font(.system(.headline, design: .rounded))
                                Spacer()
                                Text("\(note.entries.count) 条笔记")
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Capsule().fill(Color.blue.opacity(0.1)))
                            }
                            .padding(.horizontal)

                            let entries = note.entries.sorted { $0.createdAt < $1.createdAt }
                            ForEach(entries) { entry in
                                BrowseEntryRow(entry: entry)
                            }

                            if let summary = note.summary, !summary.isEmpty {
                                VStack(alignment: .leading, spacing: 6) {
                                    Label("摘要", systemImage: "text.quote")
                                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                        .foregroundStyle(.secondary)
                                    Text(summary)
                                        .font(.system(.body, design: .rounded))
                                        .foregroundStyle(.secondary)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(Color.purple.opacity(0.06))
                                )
                                .padding(.horizontal)
                            }
                        }
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "calendar.badge.exclamationmark")
                                .font(.system(size: 40))
                                .foregroundStyle(.secondary)
                                .symbolRenderingMode(.hierarchical)
                            Text("该日期没有笔记")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 30)
                    }

                    if !notes.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("近期笔记")
                                .font(.system(.headline, design: .rounded))
                                .padding(.horizontal)

                            ForEach(Array(notes.prefix(20))) { note in
                                Button {
                                    selectedDetailNote = note
                                    showDetail = true
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(note.displayDate)
                                                .font(.system(.body, design: .rounded))
                                                .foregroundStyle(.primary)
                                            if let firstEntry = note.sortedEntries.first {
                                                Text(firstEntry.content)
                                                    .font(.system(.caption, design: .rounded))
                                                    .foregroundStyle(.secondary)
                                                    .lineLimit(1)
                                            }
                                        }
                                        Spacer()
                                        Text("\(note.entries.count) 条")
                                            .font(.system(.caption, design: .rounded, weight: .medium))
                                            .foregroundStyle(.secondary)
                                        Image(systemName: "chevron.right")
                                            .font(.caption2)
                                            .foregroundStyle(.quaternary)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .fill(Color(uiColor: .systemBackground))
                                    )
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.bottom, 16)
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .sheet(isPresented: $showDetail) {
            if let note = selectedDetailNote {
                DailyNoteDetailView(dailyNote: note)
            }
        }
    }
}

struct BrowseEntryRow: View {
    let entry: NoteEntry

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            if entry.isReminder {
                Image(systemName: entry.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(entry.isCompleted ? .green : .orange)
                    .font(.system(size: 18))
            } else {
                Circle()
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .padding(.top, 6)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.content)
                    .font(.system(.body, design: .rounded))
                    .lineLimit(3)
                Text(entry.timeString)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(uiColor: .systemBackground))
        )
        .padding(.horizontal)
    }
}

struct DailyNoteDetailView: View {
    let dailyNote: DailyNote
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    let entries = dailyNote.entries.sorted { $0.createdAt < $1.createdAt }
                    ForEach(entries) { entry in
                        ChatBubbleView(entry: entry)
                    }

                    if let summary = dailyNote.summary, !summary.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Label("摘要", systemImage: "text.quote")
                                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                            Text(summary)
                                .font(.system(.body, design: .rounded))
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.purple.opacity(0.06))
                        )
                    }
                }
                .padding()
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle(dailyNote.displayDate)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") { dismiss() }
                }
            }
        }
    }
}
