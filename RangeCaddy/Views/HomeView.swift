import SwiftUI
import SwiftData

struct HomeView: View {

    @Environment(\.modelContext) private var context
    @Query(sort: \PracticeSession.createdAt, order: .reverse) private var sessions: [PracticeSession]

    @State private var showSetup = false
    @State private var resumeSession: PracticeSession?

    private var unfinished: PracticeSession? {
        sessions.first(where: { !$0.isCompleted })
    }
    private var hasCompletedSessions: Bool {
        sessions.contains(where: { $0.isCompleted })
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 8) {
                Text("Range Caddy")
                    .font(.system(size: 40, weight: .heavy))
                    .tracking(-0.5)
                Text("Tell me what you've got.\nI'll build the session.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.bottom, 32)

            Button {
                showSetup = true
            } label: {
                Text("Start Practicing")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.green)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: Color.green.opacity(0.25), radius: 14, y: 4)
            }
            .buttonStyle(.plain)

            if let unfinished {
                Button {
                    resumeSession = unfinished
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Continue last session")
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                            Text("\(unfinished.targetMinutes) min · \(unfinished.drills.count) drills")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 14)
                    .padding(.horizontal, 16)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .padding(.top, 16)
            }

            Spacer()

            if hasCompletedSessions {
                NavigationLink {
                    HistoryView()
                } label: {
                    Text("Past sessions")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding()
                }
            }
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground).ignoresSafeArea())
        .navigationBarHidden(true)
        .sheet(isPresented: $showSetup) {
            SessionSetupView()
        }
        .fullScreenCover(item: $resumeSession) { session in
            ResumeRunnerView(session: session) {
                resumeSession = nil
            }
        }
    }
}

/// Wraps DrillRunnerView + DoneView for the "resume" path from Home.
/// Presented as a full-screen cover so closing returns to Home.
private struct ResumeRunnerView: View {

    @Bindable var session: PracticeSession
    let onClose: () -> Void

    @State private var isDone: Bool

    init(session: PracticeSession, onClose: @escaping () -> Void) {
        self.session = session
        self.onClose = onClose
        self._isDone = State(initialValue: session.isCompleted)
    }

    private var startIndex: Int {
        session.orderedDrills.firstIndex(where: { $0.rating == nil }) ?? 0
    }

    var body: some View {
        if isDone {
            DoneView(session: session, onClose: onClose)
        } else {
            DrillRunnerView(
                session: session,
                startIndex: startIndex,
                onQuit: onClose,
                onComplete: { isDone = true }
            )
        }
    }
}

#Preview {
    NavigationStack { HomeView() }
        .modelContainer(for: [
            PracticeSession.self,
            DrillRecord.self,
            SkillState.self,
            UserPreferences.self,
        ], inMemory: true)
}
