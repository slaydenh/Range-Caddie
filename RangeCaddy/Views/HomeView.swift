import SwiftUI
import SwiftData

struct HomeView: View {

    @Environment(\.modelContext) private var context
    @Query(sort: \PracticeSession.createdAt, order: .reverse) private var sessions: [PracticeSession]

    @State private var showSetup = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header

                    StartCard {
                        showSetup = true
                    }

                    if let recent = sessions.first {
                        recentSessionCard(recent)
                    }

                    insightsCard
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Range Caddy")
            .sheet(isPresented: $showSetup) {
                SessionSetupView()
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Welcome back")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("Time to sharpen up.")
                .font(.title2.bold())
        }
        .padding(.top)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func recentSessionCard(_ s: PracticeSession) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Last Session", systemImage: "clock")
                    .font(.headline)
                Spacer()
                Text(s.createdAt, style: .relative)
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
            HStack(spacing: 16) {
                StatPill(value: "\(s.targetMinutes)", unit: "min")
                StatPill(value: "\(s.drills.count)", unit: "drills")
                StatPill(value: "\(s.completedDrillCount)/\(s.drills.count)", unit: "done")
            }
            NavigationLink {
                if s.isCompleted {
                    SessionSummaryView(session: s)
                } else {
                    SessionPlanView(session: s)
                }
            } label: {
                Text(s.isCompleted ? "View summary" : "Resume session")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.green.opacity(0.15))
                    .foregroundStyle(.green)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var insightsCard: some View {
        let means = BayesianModel.currentMeans(in: context)
        let weakest = means
            .filter { $0.value < 0.5 }
            .sorted { $0.value < $1.value }
            .prefix(3)
        return VStack(alignment: .leading, spacing: 10) {
            Label("What we're working on", systemImage: "scope")
                .font(.headline)
            if weakest.isEmpty {
                Text("Once you log a few sessions, your top focus areas show up here.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(Array(weakest), id: \.key) { (skill, mean) in
                    HStack {
                        Text(skill.displayName)
                        Spacer()
                        Text(String(format: "%.0f%%", mean * 100))
                            .foregroundStyle(.secondary)
                    }
                    .font(.subheadline)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Sub-components

private struct StartCard: View {
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                    Text("New Session")
                        .font(.title2.bold())
                }
                Text("Tell us your facility, time, and clubs — we'll build the session.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.85))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(
                LinearGradient(colors: [.green, .green.opacity(0.7)],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
            )
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

private struct StatPill: View {
    let value: String
    let unit: String
    var body: some View {
        VStack(spacing: 2) {
            Text(value).font(.title3.bold())
            Text(unit).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(.tertiarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [
            PracticeSession.self,
            DrillRecord.self,
            SkillState.self,
            UserPreferences.self,
        ], inMemory: true)
}
