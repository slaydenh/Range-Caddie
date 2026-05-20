import SwiftUI
import SwiftData

/// End-of-session view: drill outcomes + how the skill posteriors moved.
struct SessionSummaryView: View {

    @Bindable var session: PracticeSession
    @Environment(\.modelContext) private var context

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerCard
                drillResults
                skillDelta
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Summary")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(session.createdAt, style: .date)
                .font(.subheadline).foregroundStyle(.secondary)
            HStack {
                Label(session.facility.displayName, systemImage: session.facility.symbolName)
                Spacer()
                Label("\(session.targetMinutes) min", systemImage: "clock")
            }
            .font(.subheadline)
            HStack {
                Label("\(session.drills.count) drills", systemImage: "list.bullet")
                Spacer()
                Label("\(session.completedDrillCount) rated",
                      systemImage: "checkmark.circle")
                    .foregroundStyle(.green)
            }
            .font(.subheadline)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var drillResults: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Drills").font(.headline)
            ForEach(session.orderedDrills) { record in
                if let drill = record.drill {
                    HStack(alignment: .top) {
                        Image(systemName: record.phase.symbolName)
                            .foregroundStyle(.green)
                            .frame(width: 24)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(drill.name).font(.subheadline.bold())
                            Text(drill.summary)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                            if !record.notes.isEmpty {
                                Text("“\(record.notes)”")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .italic()
                            }
                        }
                        Spacer()
                        if let r = record.rating {
                            VStack(alignment: .trailing) {
                                Image(systemName: r.symbolName)
                                    .foregroundStyle(color(for: r))
                                Text(r.displayName)
                                    .font(.caption2)
                                    .foregroundStyle(color(for: r))
                            }
                        } else {
                            Text("—")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var skillDelta: some View {
        let before = session.decodeSnapshot()
        let after  = BayesianModel.currentMeans(in: context)
        // Only show skills that the session actually touched (have a delta).
        let entries = SkillArea.allCases
            .compactMap { s -> (SkillArea, Double, Double, Double)? in
                let b = before[s] ?? 0.5
                let a = after[s] ?? b
                let d = a - b
                if abs(d) < 0.005 { return nil }
                return (s, b, a, d)
            }
            .sorted { abs($0.3) > abs($1.3) }
        return VStack(alignment: .leading, spacing: 12) {
            Text("How your model moved").font(.headline)
            if entries.isEmpty {
                Text("No skill changes recorded yet — rate some drills to update.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(entries, id: \.0) { entry in
                    let (skill, before, after, delta) = entry
                    HStack {
                        Text(skill.displayName).font(.subheadline)
                        Spacer()
                        Text(String(format: "%.0f%% → %.0f%%", before * 100, after * 100))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(String(format: "%+.0f", delta * 100))
                            .font(.caption.bold())
                            .foregroundStyle(delta > 0 ? .green : .red)
                            .frame(width: 40, alignment: .trailing)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func color(for r: DrillRating) -> Color {
        switch r {
        case .poor, .belowAverage:  return .red
        case .average:              return .orange
        case .good, .excellent:     return .green
        }
    }
}
