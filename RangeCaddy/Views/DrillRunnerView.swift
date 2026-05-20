import SwiftUI
import SwiftData

/// Walks the user through one drill at a time. Steps, pass criteria, and a
/// 3-button rating at the bottom. No timer controls — just shows the
/// suggested duration. Tapping a rating immediately advances to the next
/// drill. When the last drill is rated, calls `onComplete`.
struct DrillRunnerView: View {

    @Bindable var session: PracticeSession
    let startIndex: Int

    /// Called when the user quits mid-session (top-left button).
    let onQuit: () -> Void

    /// Called after the user rates the final drill of the session.
    let onComplete: () -> Void

    @Environment(\.modelContext) private var context

    @State private var index: Int

    init(session: PracticeSession,
         startIndex: Int,
         onQuit: @escaping () -> Void,
         onComplete: @escaping () -> Void) {
        self.session = session
        self.startIndex = startIndex
        self.onQuit = onQuit
        self.onComplete = onComplete
        let safeStart = max(0, min(startIndex, max(session.drills.count - 1, 0)))
        self._index = State(initialValue: safeStart)
    }

    private var ordered: [DrillRecord] { session.orderedDrills }
    private var currentRecord: DrillRecord? {
        guard index >= 0, index < ordered.count else { return nil }
        return ordered[index]
    }
    private var currentDrill: Drill? { currentRecord?.drill }

    var body: some View {
        VStack(spacing: 0) {
            topBar
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    if let record = currentRecord, let drill = currentDrill {
                        phaseTag(record.phase)
                        Text(drill.name)
                            .font(.system(size: 30, weight: .heavy))
                        Text(drill.summary)
                            .font(.body)
                            .foregroundStyle(.secondary)
                        Label("\(record.plannedMinutes) min suggested", systemImage: "clock")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        stepsList(drill.instructions)
                        passCard(drill.successCriteria)
                        ratingRow()
                    } else {
                        Text("No drills in this session.")
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(20)
            }
            .id(index)  // recreate scroll view on drill change to reset position
        }
        .background(Color(.systemBackground).ignoresSafeArea())
    }

    // MARK: - Sub-views

    private var topBar: some View {
        HStack {
            Button(action: onQuit) {
                Text("‹ Quit")
                    .font(.body)
                    .foregroundStyle(Color.green)
            }
            .buttonStyle(.plain)
            Spacer()
            Text("\(index + 1) of \(ordered.count)")
                .font(.subheadline.bold())
                .foregroundStyle(.secondary)
            Spacer()
            // Spacer to balance the layout
            Text("‹ Quit").font(.body).opacity(0)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    private func phaseTag(_ phase: SessionPhase) -> some View {
        Text(phase.displayName.uppercased())
            .font(.caption.bold())
            .tracking(0.8)
            .foregroundStyle(Color.green)
    }

    private func stepsList(_ steps: [String]) -> some View {
        VStack(spacing: 8) {
            ForEach(Array(steps.enumerated()), id: \.offset) { (idx, step) in
                HStack(alignment: .top, spacing: 12) {
                    Text("\(idx + 1)")
                        .font(.caption.bold())
                        .foregroundStyle(Color.green)
                        .frame(width: 24, height: 24)
                        .background(Color.green.opacity(0.12))
                        .clipShape(Circle())
                    Text(step).font(.body)
                    Spacer(minLength: 0)
                }
                .padding(12)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private func passCard(_ criteria: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("PASS WHEN")
                .font(.caption.bold())
                .tracking(0.8)
                .foregroundStyle(Color.green)
            Text(criteria).font(.body)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.green.opacity(0.10))
        .overlay(
            Rectangle()
                .fill(Color.green)
                .frame(width: 3),
            alignment: .leading
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func ratingRow() -> some View {
        VStack(spacing: 12) {
            Text("HOW'D THAT GO?")
                .font(.caption.bold())
                .tracking(0.8)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
            HStack(spacing: 10) {
                ForEach(DrillRating.allCases) { r in
                    Button { rate(r) } label: {
                        VStack(spacing: 6) {
                            Text(r.emoji).font(.system(size: 28))
                            Text(r.displayName).font(.subheadline.bold())
                        }
                        .frame(maxWidth: .infinity, minHeight: 76)
                        .padding(.vertical, 14)
                        .background(Color(.secondarySystemGroupedBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(borderColor(for: r), lineWidth: 2)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .foregroundStyle(Color.primary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.top, 8)
    }

    private func borderColor(for r: DrillRating) -> Color {
        switch r {
        case .struggled: return Color.red.opacity(0.4)
        case .solid:     return Color.orange.opacity(0.4)
        case .dialed:    return Color.green.opacity(0.4)
        }
    }

    // MARK: - Actions

    private func rate(_ rating: DrillRating) {
        guard let record = currentRecord, let drill = currentDrill else { return }
        record.ratingRaw = rating.rawValue
        record.completedAt = Date()
        BayesianModel.applyRating(rating, for: drill, in: context)

        if index < ordered.count - 1 {
            index += 1
            try? context.save()
        } else {
            if !session.isCompleted {
                session.completedAt = Date()
            }
            try? context.save()
            onComplete()
        }
    }
}
