import SwiftUI
import Combine

// MARK: - JSON models (speakers.json)

struct SpeakersPayload: Codable {
    let speakers: [SpeakerRaw]
}

struct SpeakerRaw: Codable {
    let name: String
    let bio: String
}

// MARK: - App model

struct Speaker: Identifiable {
    let id = UUID()
    let name: String
    let bio: String

    // Best-effort surname sort key
    var sortSurname: String {
        let cleaned = name
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return cleaned.split(separator: " ").last.map(String.init) ?? cleaned
    }

    // Automatic photo asset name based on speaker name.
    // Example: "Professor Tony Avery OBE" -> "tony_avery"
    var photoAssetName: String {
        Speaker.slugForPhoto(from: name)
    }

    static func slugForPhoto(from rawName: String) -> String {
        // 1) Lowercase + trim
        var s = rawName.lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)

        // 2) Remove common titles/honorifics at the start
        let prefixes = [
            "dr ", "dr. ",
            "professor ", "prof ", "prof. ",
            "mr ", "mr. ",
            "mrs ", "mrs. ",
            "ms ", "ms. "
        ]
        for p in prefixes {
            if s.hasPrefix(p) { s.removeFirst(p.count) }
        }

        // 3) Remove some common suffix tokens (extend if needed)
        s = s
            .replacingOccurrences(of: " obe", with: "")
            .replacingOccurrences(of: " mbe", with: "")
            .replacingOccurrences(of: " cbe", with: "")

        // 4) Remove punctuation
        s = s
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: "’", with: "'")

        // 5) Keep only letters/numbers/spaces/hyphen; everything else becomes a space
        let allowed = CharacterSet.alphanumerics.union(.whitespaces).union(CharacterSet(charactersIn: "-"))
        s = String(s.unicodeScalars.map { allowed.contains($0) ? Character($0) : " " })

        // 6) Convert hyphens to spaces, collapse whitespace, join with underscores
        s = s
            .replacingOccurrences(of: "-", with: " ")
            .split(whereSeparator: { $0 == " " || $0 == "_" })
            .map(String.init)
            .joined(separator: "_")

        return s
    }
}

// MARK: - Store

final class SpeakersStore: ObservableObject {
    @Published var speakers: [Speaker] = []
    @Published var loadError: String?

    func loadFromBundle() {
        // Case-sensitive: expects speakers.json
        guard let url = Bundle.main.url(forResource: "speakers", withExtension: "json") else {
            DispatchQueue.main.async {
                self.loadError = """
                speakers.json not found in app bundle.

                Fix:
                • Ensure the file is named exactly speakers.json
                • Ensure it is ticked in Target Membership
                • Ensure it appears in Build Phases → Copy Bundle Resources
                """
            }
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let data = try Data(contentsOf: url)
                let payload = try JSONDecoder().decode(SpeakersPayload.self, from: data)

                let mapped = payload.speakers.map { raw in
                    Speaker(
                        name: raw.name.trimmingCharacters(in: .whitespacesAndNewlines),
                        bio: raw.bio.trimmingCharacters(in: .whitespacesAndNewlines)
                    )
                }

                // Sort by surname, then full name
                let sorted = mapped.sorted {
                    let a = $0.sortSurname
                    let b = $1.sortSurname
                    let primary = a.localizedCaseInsensitiveCompare(b)
                    if primary != .orderedSame { return primary == .orderedAscending }
                    return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
                }

                DispatchQueue.main.async {
                    self.speakers = sorted
                    self.loadError = nil
                }
            } catch {
                DispatchQueue.main.async {
                    self.loadError = "Failed to load speakers: \(error.localizedDescription)"
                }
            }
        }
    }
}

// MARK: - Speakers View (Grid cards)

struct SpeakersView: View {
    @StateObject private var store = SpeakersStore()
    @State private var searchText: String = ""

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    private var filtered: [Speaker] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return store.speakers }
        return store.speakers.filter {
            $0.name.localizedCaseInsensitiveContains(q) ||
            $0.bio.localizedCaseInsensitiveContains(q)
        }
    }

    var body: some View {
        Group {
            if let err = store.loadError {
                SpeakersErrorView(message: err)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {

                        Text("Speakers")
                            .font(.largeTitle.bold())
                            .foregroundColor(.primaryBlue)
                            .padding(.horizontal)
                            .padding(.top, 8)

                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(filtered) { speaker in
                                NavigationLink(destination: SpeakerDetailView(speaker: speaker)) {
                                    SpeakerCard(speaker: speaker)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)

                        Spacer(minLength: 24)
                    }
                }
            }
        }
        .background(Color.appBackground)
        .navigationTitle("Speakers")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { NavBrandLogo() }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .onAppear { store.loadFromBundle() }
    }
}

// MARK: - Speaker Card

struct SpeakerCard: View {
    let speaker: Speaker

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Spacer()
                SpeakerPhoto(assetName: speaker.photoAssetName, size: 76)
                Spacer()
            }

            Text(speaker.name)
                .font(.headline)
                .foregroundColor(.primaryText)
                .lineLimit(2)

            if speaker.bio.isEmpty {
                Text("Bio to follow")
                    .font(.subheadline)
                    .foregroundColor(.secondaryText)
                    .lineLimit(2)
            } else {
                Text(speaker.bio)
                    .font(.subheadline)
                    .foregroundColor(.secondaryText)
                    .lineLimit(3)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBackground)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.dividerGrey, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Detail View

struct SpeakerDetailView: View {
    let speaker: Speaker

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {

                HStack {
                    Spacer()
                    SpeakerPhoto(assetName: speaker.photoAssetName, size: 150)
                    Spacer()
                }
                .padding(.top, 8)

                Text(speaker.name)
                    .font(.title2.bold())
                    .foregroundColor(.primaryText)

                Divider().overlay(Color.dividerGrey)

                Text(speaker.bio.isEmpty ? "Bio to follow." : speaker.bio)
                    .font(.body)
                    .foregroundColor(.primaryText)
                    .fixedSize(horizontal: false, vertical: true)

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
        .navigationTitle("Speaker")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { NavBrandLogo() }
    }
}

// MARK: - Photo helper
// This will show the image if the asset exists (matching slug), otherwise a placeholder.

struct SpeakerPhoto: View {
    let assetName: String
    let size: CGFloat

    var body: some View {
        Group {
            if UIImage(named: assetName) != nil {
                Image(assetName)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    Circle().fill(Color.dividerGrey.opacity(0.55))
                    Image(systemName: "person.fill")
                        .font(.system(size: size * 0.40, weight: .semibold))
                        .foregroundColor(.secondaryText)
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.dividerGrey, lineWidth: 1))
    }
}

// MARK: - Nav Bar Logo (LOCKED SPEC)


    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Image("conferenceLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .padding(2)
                .background(Color.cardBackground)
                .cornerRadius(2)
                .overlay(
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(Color.dividerGrey, lineWidth: 1)
                )
                .accessibilityHidden(true)
        }
    }


// MARK: - Error view

struct SpeakersErrorView: View {
    let message: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Speakers")
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
        .navigationTitle("Speakers")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { NavBrandLogo() }
    }
}

#Preview {
    NavigationStack {
        SpeakersView()
    }
}
