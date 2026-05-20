import SwiftUI
import SwiftData

/// Modal sheet shown when the user finishes a drill.
/// Captures the rating + notes and feeds the Bayesian model.
struct DrillRatingView: View {

    @Bindable var record: DrillRecord
    let drill: Drill
    var onComplete: () -> Void

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var selected: DrillRating?
    @State private var notes: String = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(drill.name).font(.title2.bold())
                        Text(drill.successCriteria)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("How did that go?")
                            .font(.headline)
                        ForEach(DrillRating.allCases.reversed()) { r in
                            ratingButton(r)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes (optional)").font(.headline)
                        TextField("Anything you noticed…", text: $notes, axis: .vertical)
                            .lineLimit(3...6)
                            .padding(8)
                            .background(Color(.tertiarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding()
            }
            .navigationTitle("Rate Drill")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Skip") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(selected == nil)
                }
            }
            .onAppear {
                selected = record.rating
                notes = record.notes
            }
        }
    }

    private func ratingButton(_ r: DrillRating) -> some View {
        Button {
            selected = r
        } label: {
            HStack {
                Image(systemName: r.symbolName)
                    .foregroundStyle(color(for: r))
                Text(r.displayName).font(.body)
                Spacer()
                if selected == r {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.green)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(selected == r
                        ? color(for: r).opacity(0.15)
                        : Color(.tertiarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .foregroundStyle(.primary)
        }
        .buttonStyle(.plain)
    }

    private func color(for r: DrillRating) -> Color {
        switch r {
        case .poor:          return .red
        case .belowAverage:  return .orange
        case .average:       return .yellow
        case .good:          return .mint
        case .excellent:     return .green
        }
    }

    private func save() {
        guard let rating = selected else { return }
        record.ratingRaw = rating.rawValue
        record.notes = notes
        record.completedAt = Date()

        // Apply rating to the Bayesian model.
        BayesianModel.applyRating(rating, for: drill, in: context)
        do { try context.save() }
        catch { print("Save failed: \(error)") }

        dismiss()
        // Let parent advance after dismissal.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            onComplete()
        }
    }
}
