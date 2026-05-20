import SwiftUI
import SwiftData

struct SessionSetupView: View {

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query private var preferencesList: [UserPreferences]

    @State private var facility: Facility = .fullFacility
    @State private var clubs: Set<ClubCategory> = [.putter, .wedges, .shortIrons, .midIrons, .driver]
    @State private var targetMinutes: Double = 45

    @State private var generatedSession: PracticeSession?

    private var prefs: UserPreferences? { preferencesList.first }

    var body: some View {
        NavigationStack {
            Form {
                Section("Time") {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("\(Int(targetMinutes)) minutes")
                                .font(.title2.bold())
                            Spacer()
                            Text(durationLabel)
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $targetMinutes, in: 30...60, step: 5)
                            .tint(.green)
                    }
                }

                Section("Facility") {
                    Picker("Where are you practicing?", selection: $facility) {
                        ForEach(Facility.allCases) { f in
                            Label(f.displayName, systemImage: f.symbolName).tag(f)
                        }
                    }
                    .pickerStyle(.navigationLink)

                    // Inline summary of what's available.
                    HStack(spacing: 12) {
                        FacilityIndicator(label: "Range", on: facility.hasFullSwingArea)
                        FacilityIndicator(label: "Short game", on: facility.hasShortGameArea)
                        FacilityIndicator(label: "Putting", on: facility.hasPuttingGreen)
                    }
                    .padding(.top, 4)
                }

                Section {
                    ClubMultiSelect(selection: $clubs)
                } header: {
                    Text("Clubs you have / want to use")
                } footer: {
                    Text("Drills are filtered to only use clubs you've selected.")
                }

                Section {
                    Button(action: generate) {
                        HStack {
                            Spacer()
                            Text("Generate Session")
                                .font(.headline)
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                    .disabled(clubs.isEmpty)
                }
            }
            .navigationTitle("New Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear(perform: loadPreferences)
            .navigationDestination(item: $generatedSession) { s in
                SessionPlanView(session: s)
            }
        }
    }

    private var durationLabel: String {
        switch Int(targetMinutes) {
        case ..<35:  return "Quick"
        case 35...45: return "Standard"
        default:     return "Deep work"
        }
    }

    private func loadPreferences() {
        if let p = prefs {
            facility = p.lastFacility
            clubs = p.lastClubs
            targetMinutes = Double(p.lastTargetMinutes)
        }
    }

    private func generate() {
        guard !clubs.isEmpty else { return }

        // Persist prefs.
        let p = prefs ?? UserPreferences()
        if prefs == nil { context.insert(p) }
        p.lastFacility = facility
        p.lastClubs = clubs
        p.lastTargetMinutes = Int(targetMinutes)

        let gen = SessionGenerator(
            facility: facility,
            selectedClubs: clubs,
            targetMinutes: Int(targetMinutes),
            context: context
        )
        let session = gen.generate()
        do { try context.save() } catch {
            // Non-fatal — show the session anyway, but log.
            print("Save failed: \(error)")
        }
        generatedSession = session
    }
}

// MARK: - Helpers

private struct FacilityIndicator: View {
    let label: String
    let on: Bool

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: on ? "checkmark.circle.fill" : "xmark.circle")
                .foregroundStyle(on ? Color.green : .secondary)
            Text(label).font(.caption)
        }
    }
}

private struct ClubMultiSelect: View {
    @Binding var selection: Set<ClubCategory>

    var body: some View {
        let columns = [GridItem(.adaptive(minimum: 140), spacing: 8)]
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(ClubCategory.allCases) { c in
                let on = selection.contains(c)
                Button {
                    if on { selection.remove(c) } else { selection.insert(c) }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: c.symbolName)
                        Text(c.displayName).font(.subheadline)
                        Spacer(minLength: 0)
                        if on {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 10)
                    .background(on ? Color.green.opacity(0.15) : Color(.tertiarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .foregroundStyle(on ? Color.green : Color.primary)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    SessionSetupView()
        .modelContainer(for: [
            PracticeSession.self,
            DrillRecord.self,
            SkillState.self,
            UserPreferences.self,
        ], inMemory: true)
}
