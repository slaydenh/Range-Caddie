import SwiftUI
import SwiftData

/// Shows the generated drill list, lets the user start the runner, jump to any drill,
/// or regenerate.
struct SessionPlanView: View {

    @Bindable var session: PracticeSession
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var runnerStart: RunnerStart?
    @State private var showSummary: Bool = false

    var body: some View {
        List {
            Section {
                planSummary
            }

            ForEach(session.orderedDrills) { record in
                if let d = record.drill {
                    NavigationLink {
                        DrillRunnerView(session: session,
                                        startIndex: record.order)
                    } label: {
                        DrillRow(record: record, drill: d)
                    }
                }
            }

            Section {
                Button {
                    runnerStart = RunnerStart(index: firstUnratedIndex())
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text(session.completedDrillCount == 0
                             ? "Start Session"
                             : "Resume Session")
                            .font(.headline)
                        Spacer()
                    }
                }

                if session.completedDrillCount == session.drills.count
                    && !session.isCompleted {
                    Button {
                        finalize()
                    } label: {
                        Label("Finish & Save", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Your Session")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $runnerStart) { start in
            DrillRunnerView(session: session, startIndex: start.index)
        }
        .navigationDestination(isPresented: $showSummary) {
            SessionSummaryView(session: session)
        }
    }

    private var planSummary: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("\(session.targetMinutes) min", systemImage: "clock")
                Spacer()
                Label("\(session.drills.count) drills", systemImage: "list.bullet")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            HStack {
                Image(systemName: session.facility.symbolName)
                Text(session.facility.displayName)
            }
            .font(.subheadline)

            ProgressView(value: Double(session.completedDrillCount),
                         total: Double(max(session.drills.count, 1)))
                .tint(.green)
        }
        .padding(.vertical, 4)
    }

    // MARK: - Actions

    private func firstUnratedIndex() -> Int {
        if let first = session.orderedDrills.firstIndex(where: { $0.rating == nil }) {
            return first
        }
        return 0
    }

    private func finalize() {
        session.completedAt = Date()
        try? context.save()
        showSummary = true
    }
}

// MARK: - Drill row

private struct DrillRow: View {
    let record: DrillRecord
    let drill: Drill

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Label(record.phase.displayName, systemImage: record.phase.symbolName)
                    .font(.caption.bold())
                    .padding(.vertical, 3).padding(.horizontal, 7)
                    .background(Color.green.opacity(0.15))
                    .foregroundStyle(.green)
                    .clipShape(Capsule())
                Spacer()
                if let r = record.rating {
                    Label(r.displayName, systemImage: r.symbolName)
                        .font(.caption.bold())
                        .foregroundStyle(ratingColor(r))
                } else {
                    Text("\(record.plannedMinutes) min")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Text(drill.name).font(.headline)
            Text(drill.summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(.vertical, 4)
    }

    private func ratingColor(_ r: DrillRating) -> Color {
        switch r {
        case .poor, .belowAverage: return .red
        case .average: return .orange
        case .good, .excellent: return .green
        }
    }
}

/// Hashable wrapper so we can drive `.navigationDestination(item:)` with an index.
struct RunnerStart: Hashable, Identifiable {
    let index: Int
    var id: Int { index }
}
