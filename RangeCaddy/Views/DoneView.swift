import SwiftUI
import SwiftData

/// End-of-session screen. Minimal — one button to close the whole flow.
struct DoneView: View {

    let session: PracticeSession
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(Color.green)
            Text("Nice work.")
                .font(.system(size: 32, weight: .heavy))
            Text("\(session.drills.count) drills · \(session.targetMinutes) min\nThe model just learned from this one.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
            Button(action: onClose) {
                Text("Done")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.green)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
        }
        .padding(24)
        .background(Color(.systemBackground).ignoresSafeArea())
    }
}
