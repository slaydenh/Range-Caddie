import SwiftUI
import SwiftData

struct HistoryView: View {

    @Query(sort: \PracticeSession.createdAt, order: .reverse) private var sessions: [PracticeSession]
    @Environment(\.modelContext) private var context

    var body: some View {
        NavigationStack {
            Group {
                if sessions.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(sessions) { s in
                            NavigationLink {
                                if s.isCompleted {
                                    SessionSummaryView(session: s)
                                } else {
                                    SessionPlanView(session: s)
                                }
                            } label: {
                                row(for: s)
                            }
                        }
                        .onDelete(perform: deleteSessions)
                    }
                }
            }
            .navigationTitle("History")
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 56))
                .foregroundStyle(.secondary)
            Text("No sessions yet")
                .font(.headline)
            Text("Generate one from the Practice tab to get started.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }

    private func row(for s: PracticeSession) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(s.createdAt, style: .date)
                    .font(.subheadline.bold())
                Spacer()
                if s.isCompleted {
                    Text("Done")
                        .font(.caption.bold())
                        .padding(.vertical, 3).padding(.horizontal, 7)
                        .background(Color.green.opacity(0.15))
                        .foregroundStyle(.green)
                        .clipShape(Capsule())
                } else {
                    Text("In progress")
                        .font(.caption.bold())
                        .padding(.vertical, 3).padding(.horizontal, 7)
                        .background(Color.orange.opacity(0.15))
                        .foregroundStyle(.orange)
                        .clipShape(Capsule())
                }
            }
            HStack(spacing: 12) {
                Label(s.facility.displayName, systemImage: s.facility.symbolName)
                Label("\(s.targetMinutes) min", systemImage: "clock")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }

    private func deleteSessions(at offsets: IndexSet) {
        for idx in offsets {
            context.delete(sessions[idx])
        }
        try? context.save()
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: [
            PracticeSession.self,
            DrillRecord.self,
            SkillState.self,
            UserPreferences.self,
        ], inMemory: true)
}
