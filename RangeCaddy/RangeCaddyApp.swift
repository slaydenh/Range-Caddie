import SwiftUI
import SwiftData

@main
struct RangeCaddyApp: App {

    /// Shared SwiftData container for the whole app.
    let container: ModelContainer

    init() {
        do {
            let schema = Schema([
                PracticeSession.self,
                DrillRecord.self,
                SkillState.self,
                UserPreferences.self,
            ])
            let config = ModelConfiguration(schema: schema,
                                            isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
