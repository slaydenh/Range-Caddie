import SwiftUI
import SwiftData

/// Sheet content that owns the entire new-session flow:
///   Setup form → Drill runner → Done screen
/// No NavigationStack inside, so closing from any phase dismisses the sheet.
struct SessionSetupView: View {

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var flowSession: PracticeSession?
    @State private var phase: Phase = .form

    private enum Phase {
        case form
        case running
        case done
    }

    var body: some View {
        Group {
            switch phase {
            case .form:
                SetupFormView(
                    onCancel: { dismiss() },
                    onGenerate: { session in
                        flowSession = session
                        phase = .running
                    }
                )
            case .running:
                if let s = flowSession {
                    DrillRunnerView(
                        session: s,
                        startIndex: 0,
                        onQuit: { dismiss() },
                        onComplete: { phase = .done }
                    )
                } else {
                    fallback
                }
            case .done:
                if let s = flowSession {
                    DoneView(session: s) { dismiss() }
                } else {
                    fallback
                }
            }
        }
    }

    private var fallback: some View {
        VStack {
            Text("Something went wrong.")
                .foregroundStyle(.secondary)
            Button("Close") { dismiss() }
                .padding()
        }
    }
}

// MARK: - Setup form

private struct SetupFormView: View {

    var onCancel: () -> Void
    var onGenerate: (PracticeSession) -> Void

    @Environment(\.modelContext) private var context
    @Query private var preferencesList: [UserPreferences]

    @State private var minutes: Int = 45
    @State private var facility: Facility = .fullFacility
    @State private var clubs: Set<ClubBucket> = [.putter, .wedges, .irons, .driver]

    private let timeOptions = [30, 45, 60]
    private let twoCols = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]
    private var prefs: UserPreferences? { preferencesList.first }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Cancel", action: onCancel)
                    .foregroundStyle(Color.green)
                Spacer()
                Text("New Session")
                    .font(.headline)
                Spacer()
                // Symmetry placeholder
                Text("Cancel").opacity(0)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {

                    section("How long?") {
                        HStack(spacing: 10) {
                            ForEach(timeOptions, id: \.self) { t in
                                TileButton(isOn: minutes == t) {
                                    minutes = t
                                } label: {
                                    VStack(spacing: 2) {
                                        Text("\(t)")
                                            .font(.system(size: 22, weight: .heavy))
                                        Text("minutes")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }

                    section("Where are you?") {
                        LazyVGrid(columns: twoCols, spacing: 10) {
                            ForEach(Facility.allCases) { f in
                                TileButton(isOn: facility == f) {
                                    facility = f
                                    pruneClubsForFacility()
                                } label: {
                                    VStack(spacing: 4) {
                                        Text(f.displayName)
                                            .font(.subheadline.bold())
                                        Text(f.subtitle)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .multilineTextAlignment(.center)
                                    }
                                }
                            }
                        }
                    }

                    section("What clubs?") {
                        LazyVGrid(columns: twoCols, spacing: 10) {
                            ForEach(ClubBucket.allCases) { b in
                                let on = clubs.contains(b)
                                let fits = b.fits(at: facility)
                                TileButton(isOn: on && fits, disabled: !fits) {
                                    if on { clubs.remove(b) } else { clubs.insert(b) }
                                } label: {
                                    VStack(spacing: 4) {
                                        Text(b.displayName)
                                            .font(.subheadline.bold())
                                        Text(!fits ? "not at this facility"
                                             : on ? "✓ selected"
                                             : "tap to add")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }

                    Button(action: generate) {
                        Text("Build my session")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(clubs.isEmpty ? Color.gray.opacity(0.4) : Color.green)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(clubs.isEmpty)
                    .buttonStyle(.plain)
                }
                .padding(20)
            }
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .onAppear(perform: loadPrefs)
    }

    // MARK: - Helpers

    @ViewBuilder
    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(.caption.bold())
                .tracking(0.6)
                .foregroundStyle(.secondary)
            content()
        }
    }

    private func loadPrefs() {
        if let p = prefs {
            facility = p.lastFacility
            clubs = p.lastClubBuckets
            minutes = p.lastTargetMinutes
            pruneClubsForFacility()
        }
    }

    private func pruneClubsForFacility() {
        clubs = clubs.filter { $0.fits(at: facility) }
        if clubs.isEmpty {
            switch facility {
            case .puttingGreenOnly: clubs = [.putter]
            case .shortGameOnly:    clubs = [.wedges]
            case .rangeOnly:        clubs = [.irons]
            case .fullFacility:     clubs = [.putter, .wedges, .irons, .driver]
            }
        }
    }

    private func generate() {
        guard !clubs.isEmpty else { return }
        let p = prefs ?? UserPreferences()
        if prefs == nil { context.insert(p) }
        p.lastFacility = facility
        p.lastClubBuckets = clubs
        p.lastTargetMinutes = minutes

        let gen = SessionGenerator(
            facility: facility,
            selectedBuckets: clubs,
            targetMinutes: minutes,
            context: context
        )
        let session = gen.generate()
        try? context.save()
        onGenerate(session)
    }
}

// MARK: - Tile button

private struct TileButton<Label: View>: View {
    let isOn: Bool
    var disabled: Bool = false
    let action: () -> Void
    @ViewBuilder let label: () -> Label

    var body: some View {
        Button(action: { if !disabled { action() } }) {
            label()
                .frame(maxWidth: .infinity, minHeight: 76)
                .padding(.vertical, 14)
                .padding(.horizontal, 8)
                .background(isOn ? Color.green.opacity(0.12) : Color(.secondarySystemGroupedBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(isOn ? Color.green : Color.clear, lineWidth: 2)
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .foregroundStyle(isOn ? Color.green : Color.primary)
                .opacity(disabled ? 0.4 : 1.0)
        }
        .buttonStyle(.plain)
        .disabled(disabled)
    }
}
