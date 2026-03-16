import SwiftUI

struct SettingsView: View {
    @StateObject private var settings = AppSettings()
    @State private var showNotificationAlert = false

    var body: some View {
        VStack(spacing: 0) {
            // 顶部栏：标题居中
            Text("设置")
                .font(.system(.headline, design: .rounded, weight: .semibold))
                .padding(.top, 12)
                .padding(.bottom, 8)
                .frame(maxWidth: .infinity)
                .background(Color(uiColor: .systemGroupedBackground))

            ScrollView {
                VStack(spacing: 20) {
                    // 数据同步
                    settingsSection(title: "数据同步") {
                        VStack(spacing: 0) {
                            Toggle(isOn: $settings.enableiCloud) {
                                Label("iCloud 同步", systemImage: "icloud")
                                    .font(.system(.body, design: .rounded))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)

                            if settings.enableiCloud {
                                Text("笔记将通过 iCloud 在你的 Apple 设备间同步")
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 12)
                            }
                        }
                    }

                    // 提醒
                    settingsSection(title: "提醒") {
                        VStack(spacing: 0) {
                            Toggle(isOn: $settings.dailyReminderEnabled) {
                                Label("每日提醒", systemImage: "bell.badge")
                                    .font(.system(.body, design: .rounded))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
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
                                .font(.system(.body, design: .rounded))
                                .environment(\.locale, Locale(identifier: "zh_CN"))
                                .padding(.horizontal, 16)
                                .padding(.bottom, 12)
                            }
                        }
                    }

                    // 智能摘要
                    settingsSection(title: "智能摘要") {
                        VStack(spacing: 0) {
                            Toggle(isOn: $settings.enableAISummary) {
                                Label("AI 摘要", systemImage: "sparkles")
                                    .font(.system(.body, design: .rounded))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)

                            if settings.enableAISummary {
                                SecureField("API Key", text: $settings.aiAPIKey)
                                    .font(.system(.body, design: .rounded))
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 4)
                                Text("留空则使用本地摘要")
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 12)
                            }

                            Text("开启后可使用 AI 生成更智能的每日摘要")
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 16)
                                .padding(.bottom, 12)
                        }
                    }

                    // 关于
                    settingsSection(title: "关于") {
                        HStack {
                            Label("版本", systemImage: "info.circle")
                                .font(.system(.body, design: .rounded))
                            Spacer()
                            Text("1.0.0")
                                .font(.system(.body, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
            .alert("需要通知权限", isPresented: $showNotificationAlert) {
                Button("好的") {}
            } message: {
                Text("请在系统设置中允许 DayNote 发送通知")
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }

    @ViewBuilder
    private func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(.caption, design: .rounded, weight: .medium))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .padding(.horizontal, 4)

            content()
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(uiColor: .systemBackground))
                )
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
