import SwiftUI

struct SettingsView: View {
    @StateObject private var settings = AppSettings()
    @State private var showNotificationAlert = false

    var body: some View {
        NavigationStack {
            Form {
                Section("数据同步") {
                    Toggle("iCloud 同步", isOn: $settings.enableiCloud)
                    if settings.enableiCloud {
                        Text("笔记将通过 iCloud 在你的 Apple 设备间同步")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("每日提醒") {
                    Toggle("开启每日提醒", isOn: $settings.dailyReminderEnabled)
                        .onChange(of: settings.dailyReminderEnabled) { _, newValue in
                            if newValue {
                                NotificationService.shared.requestPermission { granted in
                                    if !granted {
                                        settings.dailyReminderEnabled = false
                                        showNotificationAlert = true
                                    } else {
                                        scheduleDailyReminder()
                                    }
                                }
                            } else {
                                NotificationService.shared.cancelDailyReminder()
                            }
                        }

                    if settings.dailyReminderEnabled {
                        DatePicker(
                            "提醒时间",
                            selection: Binding(
                                get: { reminderDate() },
                                set: { updateReminderTime($0) }
                            ),
                            displayedComponents: .hourAndMinute
                        )
                    }
                }

                Section("智能摘要") {
                    Toggle("AI 摘要（实验性）", isOn: $settings.enableAISummary)
                    if settings.enableAISummary {
                        SecureField("API Key", text: $settings.aiAPIKey)
                        Text("留空则使用本地摘要")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("关于") {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("开发者")
                        Spacer()
                        Text("DayNote Team")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("设置")
            .alert("需要通知权限", isPresented: $showNotificationAlert) {
                Button("好的") {}
            } message: {
                Text("请在系统设置中允许 DayNote 发送通知")
            }
        }
    }

    private func reminderDate() -> Date {
        var components = DateComponents()
        components.hour = settings.dailyReminderHour
        components.minute = settings.dailyReminderMinute
        return Calendar.current.date(from: components) ?? Date()
    }

    private func updateReminderTime(_ date: Date) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        settings.dailyReminderHour = components.hour ?? 22
        settings.dailyReminderMinute = components.minute ?? 0
        scheduleDailyReminder()
    }

    private func scheduleDailyReminder() {
        NotificationService.shared.scheduleDailyReminder(
            hour: settings.dailyReminderHour,
            minute: settings.dailyReminderMinute
        )
    }
}
