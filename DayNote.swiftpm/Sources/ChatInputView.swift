import SwiftUI

struct ChatInputView: View {
    @State private var text = ""
    @State private var isReminder = false
    @State private var reminderTime = Date()
    @State private var showTimePicker = false

    var onSend: (String, Bool, Date?) -> Void

    private var canSend: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(spacing: 8) {
            if showTimePicker {
                HStack {
                    DatePicker("提醒时间", selection: $reminderTime, displayedComponents: [.date, .hourAndMinute])
                        .labelsHidden()
                        .environment(\.locale, Locale(identifier: "zh_CN"))
                    Button("确定") {
                        showTimePicker = false
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                    .clipShape(Capsule())
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }

            HStack(alignment: .center, spacing: 10) {
                // 提醒按钮
                Button {
                    isReminder.toggle()
                    if isReminder {
                        showTimePicker = true
                        reminderTime = Date().addingTimeInterval(3600)
                    } else {
                        showTimePicker = false
                    }
                } label: {
                    Image(systemName: isReminder ? "bell.fill" : "bell")
                        .font(.system(size: 18))
                        .foregroundStyle(isReminder ? .white : .secondary)
                        .frame(width: 36, height: 36)
                        .background(isReminder ? Color.orange : Color(uiColor: .systemFill))
                        .clipShape(Circle())
                }

                // 输入框
                TextField("记录点什么...", text: $text, axis: .vertical)
                    .font(.system(.body, design: .rounded))
                    .lineLimit(1...5)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .frame(minHeight: 36)
                    .background(Color(uiColor: .systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                    )

                // 发送按钮
                Button {
                    send()
                } label: {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(canSend ? Color.blue : Color.gray.opacity(0.3))
                        .clipShape(Circle())
                }
                .disabled(!canSend)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private func send() {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        onSend(trimmed, isReminder, isReminder ? reminderTime : nil)
        text = ""
        isReminder = false
        showTimePicker = false
    }
}
