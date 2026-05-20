import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        NavigationStack {
            HomeView()
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
