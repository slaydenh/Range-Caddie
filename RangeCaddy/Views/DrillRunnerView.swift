import SwiftUI
import SwiftData

/// Walks the user through one drill at a time: instructions, optional timer,
/// then rating, then advances to the next drill.
struct DrillRunnerView: View {

    @Bindable var session: PracticeSession
    let startIndex: Int

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var index: Int
    @State private var showRating: Bool = false
    @State private var elapsed: TimeInterval = 0
    @State private var running: Bool = false
    @State private var timerToken = UUID()

    init(session: PracticeSession, startIndex: Int) {
        self.session = session
        self.startIndex = startIndex
        self._index = State(initialValue: max(0, min(startIndex, session.drills.count - 1)))
    }

    private var ordered: [DrillRecord] { session.orderedDrills }
    private var currentRecord: DrillRecord? {
        guard index >= 0, index < ordered.count else { return nil }
        return ordered[index]
    }
    private var currentDrill: Drill? { currentRecord?.drill }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let record = currentRecord, let drill = currentDrill {
                    progressBar
                    header(record: record, drill: drill)
                    timerCard(planned: record.plannedMinutes)
                    instructionsCard(drill: drill)
                    successCard(drill: drill)
                    actions(record: record)
                } else {
                    finishedView
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle(currentDrill?.name ?? "Done")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showRating) {
            if let record = currentRecord, let drill = currentDrill {
                DrillRatingView(record: record, drill: drill) {
                    advance()
                }
                .presentationDetents([.medium, .large])
            }
        }
        .onAppear { resetTimer() }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            if running { elapsed += 1 }
        }
        .id(timerToken)
    }

    // MARK: - Sub-views

    private var progressBar: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Drill \(index + 1) of \(ordered.count)")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
                if let r = currentRecord {
                    Label(r.phase.displayName, systemImage: r.phase.symbolName)
                        .font(.caption.bold())
                        .foregroundStyle(.green)
                }
            }
            ProgressView(value: Double(index), total: Double(max(ordered.count, 1)))
                .tint(.green)
        }
    }

    private func header(record: DrillRecord, drill: Drill) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(drill.name).font(.title.bold())
            Text(drill.summary).foregroundStyle(.secondary)
            HStack(spacing: 8) {
                ForEach(drill.clubs, id: \.self) { c in
                    Label(c.displayName, systemImage: c.symbolName)
                        .font(.caption)
                        .padding(.vertical, 4).padding(.horizontal, 8)
                        .background(Color(.tertiarySystemGroupedBackground))
                        .clipShape(Capsule())
                }
            }
            HStack(spacing: 8) {
                ForEach(drill.skillAreas, id: \.self) { s in
                    Text(s.displayName)
                        .font(.caption2)
                        .padding(.vertical, 3).padding(.horizontal, 7)
                        .background(Color.green.opacity(0.12))
                        .foregroundStyle(.green)
                        .clipShape(Capsule())
                }
            }
        }
    }

    private func timerCard(planned: Int) -> some View {
        VStack(spacing: 12) {
            HStack {
                Label("Timer", systemImage: "timer")
                    .font(.headline)
                Spacer()
                Text("Planned \(planned) min")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            }
            Text(formatElapsed(elapsed))
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(elapsed > Double(planned) * 60 ? .orange : .primary)
            HStack(spacing: 12) {
                Button {
                    running.toggle()
                } label: {
                    Label(running ? "Pause" : (elapsed > 0 ? "Resume" : "Start"),
                          systemImage: running ? "pause.fill" : "play.fill")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.green.opacity(0.15))
                        .foregroundStyle(.green)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                Button(role: .destructive) {
                    elapsed = 0
                    running = false
                } label: {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color(.tertiarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .tint(.primary)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func instructionsCard(drill: Drill) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("How to do it", systemImage: "list.number")
                .font(.headline)
            ForEach(Array(drill.instructions.enumerated()), id: \.offset) { (idx, line) in
                HStack(alignment: .top, spacing: 10) {
                    Text("\(idx + 1).")
                        .font(.subheadline.bold())
                        .foregroundStyle(.green)
                    Text(line).font(.subheadline)
                    Spacer(minLength: 0)
                }
            }
            Divider().padding(.vertical, 2)
            HStack {
                Image(systemName: "number")
                Text("Reps: \(drill.reps)")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func successCard(drill: Drill) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Pass when…", systemImage: "checkmark.seal")
                .font(.headline)
            Text(drill.successCriteria)
                .font(.subheadline)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.green.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func actions(record: DrillRecord) -> some View {
        VStack(spacing: 10) {
            Button {
                running = false
                showRating = true
            } label: {
                Text(record.rating == nil ? "I'm done — rate it" : "Update rating")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.green)
                    .foregroundStyle(.white)
                    .font(.headline)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            if record.rating != nil, index < ordered.count - 1 {
                Button {
                    advance()
                } label: {
                    Text("Next drill")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(.tertiarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }

    private var finishedView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)
            Text("Session complete").font(.title.bold())
            NavigationLink {
                SessionSummaryView(session: session)
            } label: {
                Text("View summary")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.green)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.top, 60)
    }

    // MARK: - Logic

    private func formatElapsed(_ t: TimeInterval) -> String {
        let total = Int(t)
        let m = total / 60
        let s = total % 60
        return String(format: "%02d:%02d", m, s)
    }

    private func resetTimer() {
        elapsed = 0
        running = false
        timerToken = UUID()
    }

    private func advance() {
        if index < ordered.count - 1 {
            index += 1
            resetTimer()
        } else {
            // Finished. Mark session complete if all drills rated.
            if session.completedDrillCount == session.drills.count {
                session.completedAt = Date()
                try? context.save()
            }
            // Stay on the finished view — user can navigate to summary.
            index = ordered.count
        }
    }
}
