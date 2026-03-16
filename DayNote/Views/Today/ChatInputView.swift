import SwiftUI

struct ChatInputView: View {
    @State private var text = ""
    @State private var isReminder = false
    @State private var reminderTime = Date()
    @State private var showTimePicker = false
    @FocusState private var isFocused: Bool

    var onSend: (String, Bool, Date?) -> Void

    var body: some View {
        VStack(spacing: 8) {
            if showTimePicker {
                HStack {
                    DatePicker("提醒时间", selection: $reminderTime, displayedComponents: [.date, .hourAndMinute])
                        .labelsHidden()
                    Button("确定") {
                        showTimePicker = false
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            HStack(spacing: 8) {
                // 提醒按钮
                Button {
                    withAnimation {
                        isReminder.toggle()
                        if isReminder {
                            showTimePicker = true
                            // 默认提醒时间：1小时后
                            reminderTime = Date().addingTimeInterval(3600)
                        } else {
                            showTimePicker = false
                        }
                    }
                } label: {
                    Image(systemName: isReminder ? "bell.fill" : "bell")
                        .foregroundStyle(isReminder ? .orange : .secondary)
                }
                .buttonStyle(.plain)

                // 输入框
                TextField("输入笔记...", text: $text, axis: .vertical)
                    .textFieldStyle(.plain)
                    .lineLimit(1...5)
                    .focused($isFocused)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color(.systemGray6))
                    )
                    .onSubmit {
                        send()
                    }

                // 发送按钮
                Button {
                    send()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundStyle(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .blue)
                }
                .buttonStyle(.plain)
                .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
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
