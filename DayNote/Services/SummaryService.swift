import Foundation

class SummaryService {
    static let shared = SummaryService()

    func generateSummary(for note: DailyNote, useAI: Bool = false, apiKey: String = "") async -> String {
        let entries = note.sortedEntries

        if useAI && !apiKey.isEmpty {
            // 可选：调用 AI API 生成摘要
            return await generateAISummary(entries: entries, apiKey: apiKey)
        } else {
            // 使用本地摘要
            return LocalSummarizer.generateSummary(from: entries)
        }
    }

    private func generateAISummary(entries: [NoteEntry], apiKey: String) async -> String {
        // AI 摘要的占位实现
        // 实际使用时可接入 OpenAI / Claude API
        let allContent = entries.map { $0.content }.joined(separator: "\n")

        guard let url = URL(string: "https://api.anthropic.com/v1/messages") else {
            return LocalSummarizer.generateSummary(from: entries)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.addValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

        let body: [String: Any] = [
            "model": "claude-haiku-4-5-20251001",
            "max_tokens": 500,
            "messages": [
                ["role": "user", "content": "请用中文为以下笔记生成简洁的每日摘要（3-5句话）：\n\n\(allContent)"]
            ]
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let content = json["content"] as? [[String: Any]],
               let text = content.first?["text"] as? String {
                return text
            }
        } catch {
            // 降级到本地摘要
        }

        return LocalSummarizer.generateSummary(from: entries)
    }
}
