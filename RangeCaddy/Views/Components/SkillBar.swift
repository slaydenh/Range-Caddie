import SwiftUI
import SwiftData

/// One row in the skill dashboard. Read-only — never mutates the context.
struct SkillBar: View {

    let skill: SkillArea
    let context: ModelContext

    var body: some View {
        // Pure-lookup: nil means we haven't observed this skill yet, so we draw
        // the neutral prior without persisting anything.
        let st = BayesianModel.existingState(for: skill, in: context)
        let mean = st?.mean ?? 0.5
        let sd = st?.stddev ?? 0.25
        let obs = st?.observationCount ?? 0

        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(skill.displayName).font(.subheadline)
                Spacer()
                Text(String(format: "%.0f%%", mean * 100))
                    .font(.subheadline.bold())
                    .foregroundStyle(barColor(for: mean))
            }
            GeometryReader { proxy in
                let w = proxy.size.width
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.tertiarySystemGroupedBackground))
                        .frame(height: 10)
                    // Uncertainty band: mean ± sd
                    RoundedRectangle(cornerRadius: 4)
                        .fill(barColor(for: mean).opacity(0.25))
                        .frame(width: max(0, min(1, mean + sd) - max(0, mean - sd)) * w,
                               height: 10)
                        .offset(x: max(0, mean - sd) * w)
                    // Mean marker
                    RoundedRectangle(cornerRadius: 4)
                        .fill(barColor(for: mean))
                        .frame(width: max(2, mean * w), height: 10)
                }
            }
            .frame(height: 10)
            if obs > 0 {
                Text("\(obs) observation\(obs == 1 ? "" : "s")")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } else {
                Text("No data yet — neutral prior")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }

    private func barColor(for mean: Double) -> Color {
        switch mean {
        case ..<0.35:  return .red
        case ..<0.55:  return .orange
        case ..<0.7:   return .yellow
        case ..<0.85:  return .mint
        default:       return .green
        }
    }
}
