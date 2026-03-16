import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allNotes: [DailyNote]
    @State private var showSummary = false

    private var todayDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    private var todayNote: DailyNote? {
        allNotes.first { $0.date == todayDateString }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 聊天气泡列表
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            if let note = todayNote {
                                ForEach(note.sortedEntries) { entry in
                                    ChatBubbleView(entry: entry)
                                        .id(entry.id)
                                }
                            } else {
                                ContentUnavailableView(
                                    "今天还没有笔记",
                                    systemImage: "note.text",
                                    description: Text("在下方输入框开始记录吧")
                                )
                            }
                        }
                        .padding()
                    }
                    .onChange(of: todayNote?.entries.count) {
                        if let lastEntry = todayNote?.sortedEntries.last {
                            withAnimation {
                                proxy.scrollTo(lastEntry.id, anchor: .bottom)
                            }
                        }
                    }
                }

                Divider()

                // 输入框
                ChatInputView { content, isReminder, reminderTime in
                    addEntry(content: content, isReminder: isReminder, reminderTime: reminderTime)
                }
            }
            .navigationTitle(todayNote?.displayDate ?? todayDisplayDate())
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    if todayNote != nil {
                        Button {
                            showSummary = true
                        } label: {
                            Image(systemName: "doc.text.magnifyingglass")
                        }
                    }
                }
            }
            .sheet(isPresented: $showSummary) {
                if let note = todayNote {
                    SummarySheetView(dailyNote: note)
                }
            }
        }
    }

    private func addEntry(content: String, isReminder: Bool, reminderTime: Date?) {
        let note: DailyNote
        if let existing = todayNote {
            note = existing
        } else {
            note = DailyNote(date: todayDateString)
            modelContext.insert(note)
        }

        let entry = NoteEntry(content: content, isReminder: isReminder, reminderTime: reminderTime)
        entry.dailyNote = note
        note.entries.append(entry)

        if isReminder, let time = reminderTime {
            NotificationService.shared.scheduleReminder(entry: entry, at: time)
        }

        try? modelContext.save()
    }

    private func todayDisplayDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日 EEEE"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: Date())
    }
}
