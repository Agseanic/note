import SwiftUI

struct SummarySheetView: View {
    @Bindable var dailyNote: DailyNote
    @Environment(\.dismiss) private var dismiss
    @State private var isGenerating = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(dailyNote.displayDate)
                            .font(.system(.title2, design: .rounded, weight: .bold))

                        Text("共 \(dailyNote.entries.count) 条笔记")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)

                    if let summary = dailyNote.summary, !summary.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("今日摘要", systemImage: "sparkles")
                                .font(.system(.headline, design: .rounded))
                                .foregroundStyle(.orange)
                            
                            Text(summary)
                                .font(.system(.body, design: .rounded))
                                .lineSpacing(4)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(LinearGradient(colors: [Color.orange.opacity(0.12), Color.orange.opacity(0.04)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        )
                        .padding(.horizontal)
                    } else {
                        ContentUnavailableView(
                            "暂无摘要",
                            systemImage: "text.quote",
                            description: Text("点击右上角生成今日摘要")
                        )
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        Text("笔记记录")
                            .font(.system(.headline, design: .rounded))
                            .padding(.horizontal)

                        LazyVStack(spacing: 12) {
                            ForEach(dailyNote.sortedEntries) { entry in
                                HStack(alignment: .top, spacing: 12) {
                                    Text(entry.timeString)
                                        .font(.system(.caption, design: .rounded, weight: .medium))
                                        .foregroundStyle(.tertiary)
                                        .frame(width: 45, alignment: .leading)
                                        .padding(.top, 2)
                                    
                                    Text(entry.content)
                                        .font(.system(.body, design: .rounded))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(Color(uiColor: .systemBackground))
                                        .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("今日摘要")
            .navigationBarTitleDisplayMode(.inline)
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
