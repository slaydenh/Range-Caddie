import SwiftUI
import SwiftData

struct SkillDashboardView: View {

    @Environment(\.modelContext) private var context
    @Query private var states: [SkillState]
    @Query(sort: \PracticeSession.createdAt, order: .reverse) private var sessions: [PracticeSession]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    intro
                    groupCard(title: "Putting", areas: [
                        .puttingShort, .puttingMid, .puttingLag, .puttingBreak
                    ])
                    groupCard(title: "Short game", areas: [
                        .chippingGreenside, .chippingPitch, .wedgePartial
                    ])
                    groupCard(title: "Full swing", areas: [
                        .ironShort, .ironMid, .ironLong, .woodsHybrid,
                        .driverAccuracy, .driverDistance
                    ])
                    groupCard(title: "Game skills", areas: [
                        .mentalPressure, .transferRandom
                    ])
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Your Skills")
        }
    }

    private var intro: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Estimated mastery per skill")
                .font(.headline)
            Text("Based on \(sessions.count) session\(sessions.count == 1 ? "" : "s"). "
                 + "Bars show our current estimate; lower = needs work.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func groupCard(title: String, areas: [SkillArea]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.headline)
            ForEach(areas, id: \.self) { s in
                SkillBar(skill: s, context: context)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    SkillDashboardView()
        .modelContainer(for: [
            PracticeSession.self,
            DrillRecord.self,
            SkillState.self,
            UserPreferences.self,
        ], inMemory: true)
}
