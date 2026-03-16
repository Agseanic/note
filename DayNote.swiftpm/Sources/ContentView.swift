import SwiftUI
import SwiftData

enum AppTab: Int, CaseIterable {
    case today = 0
    case browse = 1
    case settings = 2

    var title: String {
        switch self {
        case .today: return "今天"
        case .browse: return "浏览"
        case .settings: return "设置"
        }
    }

    var icon: String {
        switch self {
        case .today: return "message"
        case .browse: return "person.2"
        case .settings: return "person"
        }
    }

    var selectedIcon: String {
        switch self {
        case .today: return "message.fill"
        case .browse: return "person.2.fill"
        case .settings: return "person.fill"
        }
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DailyNote.date, order: .reverse) private var allNotes: [DailyNote]

    @State private var selectedTab: AppTab = .today

    private var todayDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    private var todayNote: DailyNote? {
        allNotes.first { $0.date == todayDateString }
    }

    var body: some View {
        ZStack {
            // 全局统一背景色
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ZStack {
                    TodayView()
                        .opacity(selectedTab == .today ? 1 : 0)
                        .allowsHitTesting(selectedTab == .today)
                    
                    BrowseView()
                        .opacity(selectedTab == .browse ? 1 : 0)
                        .allowsHitTesting(selectedTab == .browse)
                    
                    SettingsView()
                        .opacity(selectedTab == .settings ? 1 : 0)
                        .allowsHitTesting(selectedTab == .settings)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .animation(.easeInOut(duration: 0.25), value: selectedTab)

                // Floating Capsule Tab Bar
                HStack(spacing: 8) {
                    ForEach(AppTab.allCases, id: \.rawValue) { tab in
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedTab = tab
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: selectedTab == tab ? tab.selectedIcon : tab.icon)
                                    .font(.system(size: 15))
                                Text(tab.title)
                                    .font(.system(size: 13, weight: .regular))
                            }
                            .foregroundStyle(Color.black.opacity(0.85))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(selectedTab == tab ? Color.white : Color.clear)
                                    .shadow(color: selectedTab == tab ? .black.opacity(0.12) : .clear, radius: 2, x: 0, y: 1)
                            )
                            .contentShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(6)
                .background(
                    Capsule()
                        .fill(Color(uiColor: .secondarySystemBackground))
                )
                .padding(.bottom, 24)
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [DailyNote.self, NoteEntry.self], inMemory: true)
}
