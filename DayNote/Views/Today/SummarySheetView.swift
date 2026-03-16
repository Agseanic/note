import SwiftUI

struct SummarySheetView: View {
    @Bindable var dailyNote: DailyNote
    @Environment(\.dismiss) private var dismiss
    @State private var isGenerating = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(dailyNote.displayDate)
                        .font(.headline)

                    Text("共 \(dailyNote.entries.count) 条笔记")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Divider()

                    if let summary = dailyNote.summary, !summary.isEmpty {
                        Text("今日摘要")
                            .font(.headline)
                        Text(summary)
                            .font(.body)
                    } else {
                        ContentUnavailableView(
                            "暂无摘要",
                            systemImage: "text.quote",
                            description: Text("点击下方按钮生成今日摘要")
                        )
                    }

                    Divider()

                    Text("笔记列表")
                        .font(.headline)

                    ForEach(dailyNote.sortedEntries) { entry in
                        HStack(alignment: .top) {
                            Text(entry.timeString)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(width: 50, alignment: .leading)
                            Text(entry.content)
                                .font(.body)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("今日摘要")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        generateSummary()
                    } label: {
                        if isGenerating {
                            ProgressView()
                        } else {
                            Label("生成摘要", systemImage: "sparkles")
                        }
                    }
                    .disabled(isGenerating || dailyNote.entries.isEmpty)
                }
            }
        }
        #if os(iOS)
        .presentationDetents([.medium, .large])
        #endif
    }

    private func generateSummary() {
        isGenerating = true
        let entries = dailyNote.sortedEntries
        dailyNote.summary = LocalSummarizer.generateSummary(from: entries)
        isGenerating = false
    }
}
