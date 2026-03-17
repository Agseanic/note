import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DailyNote.date, order: .reverse) private var allNotes: [DailyNote]
    @State private var showSearch = false
    @State private var showSummary = false
    @State private var searchText = ""

    private var todayDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    private var todayNote: DailyNote? {
        allNotes.first { $0.date == todayDateString }
    }

    var body: some View {
        VStack(spacing: 0) {
            // 顶部栏：标题居中，摘要在右
            ZStack {
                Text(todayNote?.displayDate ?? todayDisplayDate())
                    .font(.system(.headline, design: .rounded, weight: .semibold))

                HStack {
                    Spacer()
                    if todayNote != nil {
                        Button {
                            showSummary = true
                        } label: {
                            Image(systemName: "sparkles")
                                .font(.system(size: 17))
                                .foregroundStyle(.primary)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 0)
            .background(Color(uiColor: .systemGroupedBackground))

            // 搜索输入栏 - 与底部ChatInputView完全一样的样式
            Button {
                showSearch = true
            } label: {
                HStack(alignment: .center, spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18))
                        .foregroundStyle(.secondary)
                        .frame(width: 36, height: 36)
                        .background(Color(uiColor: .systemFill))
                        .clipShape(Circle())

                    HStack {
                        Text("搜索笔记...")
                            .font(.system(.body, design: .rounded))
                            .foregroundStyle(Color(uiColor: .placeholderText))
                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .frame(minHeight: 36)
                    .background(Color(uiColor: .systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                    )

                    Image(systemName: "arrow.up")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.gray.opacity(0.3))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(uiColor: .systemGroupedBackground))

            // 聊天气泡列表
            ScrollView(showsIndicators: false) {
                ScrollViewReader { proxy in
                    LazyVStack(spacing: 12) {
                        if let note = todayNote {
                            let entries = note.entries.sorted { $0.createdAt < $1.createdAt }
                            ForEach(entries) { entry in
                                ChatBubbleView(entry: entry)
                                    .id(entry.id)
                            }
                        } else {
                            VStack(spacing: 16) {
                                Spacer().frame(height: 100)
                                Image(systemName: "square.and.pencil.circle.fill")
                                    .font(.system(size: 64))
                                    .foregroundStyle(.tint)
                                    .symbolRenderingMode(.hierarchical)
                                Text("今天还没有笔记")
                                    .font(.system(.title3, design: .rounded, weight: .semibold))
                                    .foregroundStyle(.primary)
                                Text("在下方输入框开始记录你的第一条笔记吧")
                                    .font(.system(.subheadline, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 8)
                    .onChange(of: todayNote?.entries.count) {
                        if let lastEntry = todayNote?.entries.sorted(by: { $0.createdAt < $1.createdAt }).last {
                            withAnimation {
                                proxy.scrollTo(lastEntry.id, anchor: .bottom)
                            }
                        }
                    }
                    .onAppear {
                        if let lastEntry = todayNote?.entries.sorted(by: { $0.createdAt < $1.createdAt }).last {
                            proxy.scrollTo(lastEntry.id, anchor: .bottom)
                        }
                    }
                }
            }

            // 输入框
            ChatInputView { content, isReminder, reminderTime in
                addEntry(content: content, isReminder: isReminder, reminderTime: reminderTime)
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .sheet(isPresented: $showSearch) {
            SearchView()
        }
        .sheet(isPresented: $showSummary) {
            if let note = todayNote {
                SummarySheetView(dailyNote: note)
            }
        }
    }

    private func addEntry(content: String, isReminder: Bool, reminderTime: Date?) {
        withAnimation {
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
    }

    private func todayDisplayDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日 EEEE"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: Date())
    }
}
