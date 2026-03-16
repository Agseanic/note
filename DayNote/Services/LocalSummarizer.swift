import Foundation

struct LocalSummarizer {
    /// 从笔记条目中生成本地摘要（不依赖 AI API）
    static func generateSummary(from entries: [NoteEntry]) -> String {
        guard !entries.isEmpty else { return "今日暂无笔记。" }

        var lines: [String] = []

        lines.append("今日共记录 \(entries.count) 条笔记。")

        // 统计提醒
        let reminders = entries.filter { $0.isReminder }
        let completed = reminders.filter { $0.isCompleted }
        if !reminders.isEmpty {
            lines.append("其中 \(reminders.count) 条提醒事项，已完成 \(completed.count) 条。")
        }

        // 时间范围
        if let first = entries.first, let last = entries.last, entries.count > 1 {
            lines.append("记录时间从 \(first.timeString) 到 \(last.timeString)。")
        }

        // 关键内容摘取（取前3条的开头）
        let previews = entries.prefix(3).map { entry in
            let preview = entry.content.prefix(30)
            return "· \(preview)\(entry.content.count > 30 ? "..." : "")"
        }
        if !previews.isEmpty {
            lines.append("")
            lines.append("主要内容：")
            lines.append(contentsOf: previews)
        }

        // 未完成提醒
        let pending = reminders.filter { !$0.isCompleted }
        if !pending.isEmpty {
            lines.append("")
            lines.append("待完成提醒：")
            for item in pending {
                let preview = item.content.prefix(30)
                lines.append("☐ \(preview)")
            }
        }

        return lines.joined(separator: "\n")
    }
}
