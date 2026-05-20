import SwiftUI
import SwiftData

struct ContentView: View {

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Practice", systemImage: "figure.golf")
                }

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }

            SkillDashboardView()
                .tabItem {
                    Label("Skills", systemImage: "chart.bar.fill")
                }
        }
        .tint(.green)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [
            PracticeSession.self,
            DrillRecord.self,
            SkillState.self,
            UserPreferences.self,
        ], inMemory: true)
}
