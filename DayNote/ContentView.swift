import SwiftUI

struct ContentView: View {
    var body: some View {
        #if os(iOS)
        TabView {
            TodayView()
                .tabItem {
                    Label("今天", systemImage: "bubble.left.fill")
                }

            BrowseView()
                .tabItem {
                    Label("浏览", systemImage: "calendar")
                }

            SearchView()
                .tabItem {
                    Label("搜索", systemImage: "magnifyingglass")
                }

            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gearshape")
                }
        }
        #else
        NavigationSplitView {
            SidebarView()
        } detail: {
            TodayView()
        }
        .frame(minWidth: 700, idealWidth: 900, minHeight: 500, idealHeight: 700)
        #endif
    }
}

#if os(macOS)
struct SidebarView: View {
    enum Destination: String, CaseIterable {
        case today = "今天"
        case browse = "浏览"
        case search = "搜索"
        case settings = "设置"

        var icon: String {
            switch self {
            case .today: return "bubble.left.fill"
            case .browse: return "calendar"
            case .search: return "magnifyingglass"
            case .settings: return "gearshape"
            }
        }
    }

    @State private var selection: Destination? = .today

    var body: some View {
        List(Destination.allCases, id: \.self, selection: $selection) { dest in
            NavigationLink(value: dest) {
                Label(dest.rawValue, systemImage: dest.icon)
            }
        }
        .navigationTitle("DayNote")
        .navigationDestination(for: Destination.self) { dest in
            switch dest {
            case .today:
                TodayView()
            case .browse:
                BrowseView()
            case .search:
                SearchView()
            case .settings:
                SettingsView()
            }
        }
    }
}
#endif

#Preview {
    ContentView()
        .modelContainer(for: [DailyNote.self, NoteEntry.self], inMemory: true)
}
