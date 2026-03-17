import SwiftUI

struct SettingsView: View {
    @StateObject private var settings = AppSettings()
    @State private var showNotificationAlert = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // 标题放在ScrollView内部，消除边界线
                Text("设置")
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.top, 12)
                    .padding(.bottom, 16)

                VStack(spacing: 24) {
                    // 数据同步
                    settingsCard {
                        HStack {
                            Image(systemName: "icloud")
                                .font(.system(size: 20))
                                .foregroundStyle(.blue)
                                .frame(width: 32)
                            Text("iCloud 同步")
                                .font(.system(.body, design: .rounded))
                            Spacer()
                            Toggle("", isOn: $settings.enableiCloud)
                                .toggleStyle(.switch)
                                .labelsHidden()
                        }
                        .padding(16)

                        if settings.enableiCloud {
                            Text("笔记将通过 iCloud 在你的设备间同步")
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 16)
                                .padding(.bottom, 12)
                                .padding(.top, -4)
                        }
                    }

                    // 提醒
                    settingsCard {
                        HStack {
                            Image(systemName: "bell.badge")
                                .font(.system(size: 20))
                                .foregroundStyle(.orange)
                                .frame(width: 32)
                            Text("每日提醒")
                                .font(.system(.body, design: .rounded))
                            Spacer()
                            Toggle("", isOn: $settings.dailyReminderEnabled)
                                .toggleStyle(.switch)
                                .labelsHidden()
                        }
                        .padding(16)
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
                            HStack {
                                Text("提醒时间")
                                    .font(.system(.body, design: .rounded))
                                Spacer()
                                DatePicker(
                                    "",
                                    selection: Binding(
                                        get: { reminderDate() },
                                        set: { updateReminderTime($0) }
                                    ),
                                    displayedComponents: .hourAndMinute
                                )
                                .labelsHidden()
                                .environment(\.locale, Locale(identifier: "zh_CN"))
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 12)
                            .padding(.top, -4)
                        }
                    }

                    // 智能摘要
                    settingsCard {
                        HStack {
                            Image(systemName: "sparkles")
                                .font(.system(size: 20))
                                .foregroundStyle(.purple)
                                .frame(width: 32)
                            Text("AI 摘要")
                                .font(.system(.body, design: .rounded))
                            Spacer()
                            Toggle("", isOn: $settings.enableAISummary)
                                .toggleStyle(.switch)
                                .labelsHidden()
                        }
                        .padding(16)

                        if settings.enableAISummary {
                            VStack(alignment: .leading, spacing: 8) {
                                SecureField("API Key", text: $settings.aiAPIKey)
                                    .font(.system(.body, design: .rounded))
                                    .padding(10)
                                    .background(Color(uiColor: .systemGroupedBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                Text("留空则使用本地摘要")
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 12)
                            .padding(.top, -4)
                        }

                        Text("开启后可生成更智能的每日摘要")
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 12)
                            .padding(.top, settings.enableAISummary ? 0 : -4)
                    }

                    // 关于
                    settingsCard {
                        HStack {
                            Image(systemName: "info.circle")
                                .font(.system(size: 20))
                                .foregroundStyle(.gray)
                                .frame(width: 32)
                            Text("版本")
                                .font(.system(.body, design: .rounded))
                            Spacer()
                            Text("1.0.0")
                                .font(.system(.body, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                        .padding(16)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .alert("需要通知权限", isPresented: $showNotificationAlert) {
            Button("好的") {}
        } message: {
            Text("请在系统设置中允许 DayNote 发送通知")
        }
    }

    @ViewBuilder
    private func settingsCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            content()
        }
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(uiColor: .systemBackground))
        )
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
