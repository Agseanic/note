import Foundation
import SwiftUI

struct MarkdownParser {
    /// 将 Markdown 文本转换为 AttributedString
    static func parse(_ text: String) -> AttributedString {
        if let result = try? AttributedString(
            markdown: text,
            options: AttributedString.MarkdownParsingOptions(
                interpretedSyntax: .inlineOnlyPreservingWhitespace
            )
        ) {
            return result
        }
        return AttributedString(text)
    }

    /// 检测文本是否包含 Markdown 语法
    static func containsMarkdown(_ text: String) -> Bool {
        let patterns = [
            "\\*\\*.*\\*\\*",  // 粗体
            "\\*.*\\*",        // 斜体
            "`.*`",            // 行内代码
            "^#{1,6}\\s",     // 标题
            "^-\\s",          // 列表
            "\\[.*\\]\\(.*\\)" // 链接
        ]

        for pattern in patterns {
            if text.range(of: pattern, options: .regularExpression) != nil {
                return true
            }
        }
        return false
    }
}
