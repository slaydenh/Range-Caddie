import SwiftUI
import SwiftData

struct HistoryView: View {

    @Query(sort: \PracticeSession.createdAt, order: .reverse) private var sessions: [PracticeSession]
    @Environment(\.modelContext) private var context

    private var completedSessions: [PracticeSession] {
        sessions.filter { $0.isCompleted }
    }

    var body: some View {
        Group {
            if completedSessions.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(completedSessions) { s in
                        row(for: s)
                    }
                    .onDelete(perform: deleteSessions)
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Past sessions")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 52))
                .foregroundStyle(.secondary)
            Text("Nothing here yet")
                .font(.headline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func row(for s: PracticeSession) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(s.createdAt, format: .dateTime.weekday(.abbreviated).month(.abbreviated).day())
                .font(.subheadline.bold())
            Text("\(s.targetMinutes) min · \(s.drills.count) drills · \(s.facility.displayName)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }

    private func deleteSessions(at offsets: IndexSet) {
        for idx in offsets {
            context.delete(completedSessions[idx])
        }
        try? context.save()
    }
}

#Preview {
    NavigationStack { HistoryView() }
        .modelContainer(for: [
            PracticeSession.self,
            DrillRecord.self,
            SkillState.self,
            UserPreferences.self,
        ], inMemory: true)
}
