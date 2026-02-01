import SwiftUI
import Combine

// MARK: - Models

struct ProgrammePayload: Codable {
    let sessions: [ProgrammeSession]
}

struct ProgrammeSession: Codable, Identifiable {
    let id: String
    let start: String
    let end: String
    let type: String
    let title: String
    let speakers: [String]
    let organisation: String
    let chair: String
    let track: String
    let notes: String
}

struct ProgrammeTimeSlot: Identifiable {
    let id: String
    let start: String
    let end: String
    let sessions: [ProgrammeSession]
}

// MARK: - Store / Loader

final class ProgrammeStore: ObservableObject {
    @Published var slots: [ProgrammeTimeSlot] = []
    @Published var loadError: String?

    func loadFromBundle() {
        // NOTE: filename is case-sensitive. If your file is "Programme.json", use "Programme" below.
        guard let url = Bundle.main.url(forResource: "programme", withExtension: "json") ??
                        Bundle.main.url(forResource: "Programme", withExtension: "json") else {
            DispatchQueue.main.async {
                self.loadError = "programme.json not found in app bundle.\n\nMake sure it is added to the app target and Copy Bundle Resources."
            }
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let data = try Data(contentsOf: url)
                let payload = try JSONDecoder().decode(ProgrammePayload.self, from: data)

                // Option A: stacked entries per time slot
                let grouped = Dictionary(grouping: payload.sessions) { "\($0.start)|\($0.end)" }

                // Preserve ordering by scanning original list order
                var orderedKeys: [String] = []
                for s in payload.sessions {
                    let key = "\(s.start)|\(s.end)"
                    if !orderedKeys.contains(key) { orderedKeys.append(key) }
                }

                let builtSlots: [ProgrammeTimeSlot] = orderedKeys.compactMap { key in
                    let parts = key.split(separator: "|").map(String.init)
                    guard parts.count == 2 else { return nil }
                    return ProgrammeTimeSlot(
                        id: key,
                        start: parts[0],
                        end: parts[1],
                        sessions: grouped[key] ?? []
                    )
                }

                DispatchQueue.main.async {
                    self.slots = builtSlots
                    self.loadError = nil
                }
            } catch {
                DispatchQueue.main.async {
                    self.loadError = "Failed to load programme: \(error.localizedDescription)"
                }
            }
        }
    }
}

// MARK: - Programme View

struct ProgrammeView: View {
    @StateObject private var store = ProgrammeStore()

    var body: some View {
        Group {
            if let err = store.loadError {
                ProgrammeErrorView(message: err)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {

                        Text("Programme")
                            .font(.largeTitle.bold())
                            .foregroundColor(.primaryBlue)
                            .padding(.horizontal)
                            .padding(.top, 8)

                        ForEach(store.slots) { slot in
                            ProgrammeSlotCard(slot: slot)
                                .padding(.horizontal)
                        }

                        Spacer(minLength: 24)
                    }
                }
            }
        }
        .background(Color.appBackground)
        .navigationTitle("Programme")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Image("conferenceLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)   // bigger
                    .padding(2)
                    .background(Color.cardBackground)
                    .cornerRadius(2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.dividerGrey, lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.08), radius: 3, x: 0, y: 1)
                    .accessibilityHidden(true)
            }
        }
        .onAppear {
            store.loadFromBundle()
        }
    }
}

// MARK: - Slot Card (time header + stacked sessions)

struct ProgrammeSlotCard: View {
    let slot: ProgrammeTimeSlot

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            // Time header
            HStack(spacing: 8) {
                Text("\(slot.start)–\(slot.end)")
                    .font(.headline)
                    .foregroundColor(.primaryBlue)

                Spacer()

                // Optional track/room pill (uses first session in slot)
                if let first = slot.sessions.first, !first.track.isEmpty {
                    TrackPill(text: first.track)
                }
            }

            Divider().overlay(Color.dividerGrey)

            // Option A: stacked sessions within the time slot
            VStack(alignment: .leading, spacing: 12) {
                ForEach(slot.sessions) { s in
                    NavigationLink(destination: SessionDetailView(session: s)) {
                        SessionRow(session: s)
                    }
                    .buttonStyle(.plain)

                    if s.id != slot.sessions.last?.id {
                        Divider().overlay(Color.dividerGrey.opacity(0.9))
                    }
                }
            }
        }
        .padding(14)
        .background(Color.cardBackground)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.dividerGrey, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Session Row

struct SessionRow: View {
    let session: ProgrammeSession

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                TypePill(text: session.type)

                Text(session.title)
                    .font(.headline)
                    .foregroundColor(.primaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if !session.speakers.isEmpty {
                Text(session.speakers.joined(separator: ", "))
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.secondaryText)
            }

            if !session.organisation.isEmpty {
                Text(session.organisation)
                    .font(.subheadline)
                    .foregroundColor(.secondaryText)
            }

            if !session.chair.isEmpty {
                Text("Chair: \(session.chair)")
                    .font(.subheadline)
                    .foregroundColor(.secondaryText)
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Session Detail View

struct SessionDetailView: View {
    let session: ProgrammeSession

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {

                Text(session.title)
                    .font(.title2.bold())
                    .foregroundColor(.primaryText)

                HStack(spacing: 8) {
                    TypePill(text: session.type)

                    if !session.track.isEmpty {
                        TrackPill(text: session.track)
                    }

                    Spacer()
                }

                Text("\(session.start)–\(session.end)")
                    .font(.headline)
                    .foregroundColor(.primaryBlue)

                if !session.speakers.isEmpty {
                    infoBlock(title: "Speaker(s)", value: session.speakers.joined(separator: ", "))
                }

                if !session.organisation.isEmpty {
                    infoBlock(title: "Organisation", value: session.organisation)
                }

                if !session.chair.isEmpty {
                    infoBlock(title: "Chair", value: session.chair)
                }

                Spacer(minLength: 20)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.cardBackground)
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.dividerGrey, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
            .padding()
        }
        .background(Color.appBackground)
        .navigationTitle("Session")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Image("conferenceLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 26)
                    .accessibilityHidden(true)
            }
        }
    }

    @ViewBuilder
    private func infoBlock(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundColor(.primaryBlue)

            Text(value)
                .font(.body)
                .foregroundColor(.secondaryText)
        }
    }
}

// MARK: - Pills

struct TypePill: View {
    let text: String

    var body: some View {
        Text(text.isEmpty ? "Session" : text)
            .font(.caption.weight(.semibold))
            .foregroundColor(.primaryBlue)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.primaryBlue.opacity(0.10))
            .cornerRadius(999)
    }
}

struct TrackPill: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundColor(.accentOrange)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.accentOrange.opacity(0.12))
            .cornerRadius(999)
    }
}

// MARK: - Error View

struct ProgrammeErrorView: View {
    let message: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Programme")
                    .font(.largeTitle.bold())
                    .foregroundColor(.primaryBlue)

                Text(message)
                    .font(.body)
                    .foregroundColor(.secondaryText)

                Spacer(minLength: 0)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.cardBackground)
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.dividerGrey, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
            .padding()
        }
        .background(Color.appBackground)
        .navigationTitle("Programme")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Image("conferenceLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 26)
                    .accessibilityHidden(true)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProgrammeView()
    }
}
