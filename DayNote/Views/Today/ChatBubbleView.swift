import SwiftUI

struct ChatBubbleView: View {
    @Bindable var entry: NoteEntry
    @State private var showActions = false

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                // 内容
                HStack(spacing: 6) {
                    if entry.isReminder {
                        Button {
                            withAnimation {
                                entry.isCompleted.toggle()
                            }
                        } label: {
                            Image(systemName: entry.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(entry.isCompleted ? .green : .secondary)
                        }
                        .buttonStyle(.plain)
                    }

                    MarkdownTextView(text: entry.content)
                        .strikethrough(entry.isCompleted)
                        .foregroundStyle(entry.isCompleted ? .secondary : .primary)
                }

                // 时间和提醒标记
                HStack(spacing: 4) {
                    Text(entry.timeString)
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    if entry.isReminder, let time = entry.reminderTime {
                        Label {
                            Text(timeString(from: time))
                        } icon: {
                            Image(systemName: "bell.fill")
                        }
                        .font(.caption2)
                        .foregroundStyle(.orange)
                    }
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(entry.isReminder ? Color.orange.opacity(0.1) : Color(.systemGray6))
            )
            .frame(maxWidth: 600, alignment: .leading)
            .contextMenu {
                Button("复制", systemImage: "doc.on.doc") {
                    #if os(iOS)
                    UIPasteboard.general.string = entry.content
                    #else
                    NSPasteboard.general.setString(entry.content, forType: .string)
                    #endif
                }
                if entry.isReminder {
                    Button(entry.isCompleted ? "标记未完成" : "标记完成",
                           systemImage: entry.isCompleted ? "circle" : "checkmark.circle") {
                        entry.isCompleted.toggle()
                    }
                }
                Button("删除", systemImage: "trash", role: .destructive) {
                    if let note = entry.dailyNote {
                        note.entries.removeAll { $0.id == entry.id }
                    }
                }
            }

            Spacer(minLength: 40)
        }
    }

    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
