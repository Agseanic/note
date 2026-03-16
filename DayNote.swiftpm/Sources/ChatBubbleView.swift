import SwiftUI

struct ChatBubbleView: View {
    @Bindable var entry: NoteEntry
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack(spacing: 0) {
            // 时间居中显示
            Text(entry.timeString)
                .font(.system(.caption2, design: .rounded, weight: .medium))
                .foregroundStyle(.tertiary)
                .padding(.bottom, 6)

            // 气泡内容
            HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top, spacing: 10) {
                        if entry.isReminder {
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    entry.isCompleted.toggle()
                                }
                            } label: {
                                Image(systemName: entry.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(entry.isCompleted ? Color.green : Color.gray.opacity(0.5))
                                    .font(.system(size: 22))
                            }
                            .padding(.top, 2)
                        }

                        MarkdownTextView(text: entry.content)
                            .strikethrough(entry.isCompleted)
                            .foregroundStyle(entry.isCompleted ? .secondary : .primary)
                            .font(.system(.body, design: .rounded))
                    }

                    if entry.isReminder, let time = entry.reminderTime {
                        HStack(spacing: 4) {
                            Image(systemName: "bell.fill")
                                .font(.system(size: 10))
                            Text(formatTime(time))
                                .font(.system(.caption2, design: .rounded, weight: .bold))
                        }
                        .foregroundStyle(entry.isCompleted ? Color.secondary : Color.orange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(entry.isCompleted ? Color.gray.opacity(0.1) : Color.orange.opacity(0.12))
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color(uiColor: .systemBackground))

                        if entry.isReminder {
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(LinearGradient(
                                    colors: [Color.orange.opacity(0.12), Color.orange.opacity(0.04)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                        }
                    }
                )
                .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)

                Spacer(minLength: 40)
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 4)
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
