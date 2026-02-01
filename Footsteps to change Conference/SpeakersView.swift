import SwiftUI
import Combine

// MARK: - Models

struct SpeakersPayload: Codable {
    let speakers: [Speaker]
}

struct Speaker: Codable, Identifiable {
    let id: String
    let name: String
    let title: String
    let organisation: String
    let bio: String
    let email: String
    let social: String
    let photo: String   // e.g. "emma_davies.png"
}

// MARK: - Store

final class SpeakersStore: ObservableObject {
    @Published var speakers: [Speaker] = []
    @Published var loadError: String?

    func loadFromBundle() {
        guard let url = Bundle.main.url(forResource: "speakers", withExtension: "json") else {
            DispatchQueue.main.async {
                self.loadError = "speakers.json not found in app bundle.\n\nMake sure it is added to the app target and Copy Bundle Resources."
            }
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let data = try Data(contentsOf: url)
                let payload = try JSONDecoder().decode(SpeakersPayload.self, from: data)

                // Sort alphabetically by surname-ish (simple: by name)
                let sorted = payload.speakers.sorted {
                    let lhsSurname = $0.name.split(separator: " ").last ?? ""
                    let rhsSurname = $1.name.split(separator: " ").last ?? ""
                    return lhsSurname.localizedCaseInsensitiveCompare(rhsSurname) == .orderedAscending
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

// MARK: - Speakers View

struct SpeakersView: View {
    @StateObject private var store = SpeakersStore()

    // Simple 2-col grid that looks great on iPhone
    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        Group {
            if let err = store.loadError {
                SpeakerErrorView(message: err)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {

                        Text("Speakers")
                            .font(.largeTitle.bold())
                            .foregroundColor(.primaryBlue)
                            .padding(.horizontal)
                            .padding(.top, 8)

                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(store.speakers) { speaker in
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
                SpeakerPhoto(photoFilename: speaker.photo, size: 72)
                Spacer()
            }

            Text(speaker.name)
                .font(.headline)
                .foregroundColor(.primaryText)
                .lineLimit(2)

            Text(speaker.title)
                .font(.subheadline)
                .foregroundColor(.secondaryText)
                .lineLimit(2)

            Text(speaker.organisation)
                .font(.subheadline)
                .foregroundColor(.secondaryText)
                .lineLimit(2)
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

// MARK: - Speaker Detail

struct SpeakerDetailView: View {
    let speaker: Speaker

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {

                HStack {
                    Spacer()
                    SpeakerPhoto(photoFilename: speaker.photo, size: 140)
                    Spacer()
                }
                .padding(.top, 8)

                Text(speaker.name)
                    .font(.title2.bold())
                    .foregroundColor(.primaryText)

                Text(speaker.title)
                    .font(.headline)
                    .foregroundColor(.secondaryText)

                Text(speaker.organisation)
                    .font(.headline)
                    .foregroundColor(.secondaryText)

                Divider().overlay(Color.dividerGrey)

                Text(speaker.bio)
                    .font(.body)
                    .foregroundColor(.primaryText)
                    .fixedSize(horizontal: false, vertical: true)

                if !speaker.email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    infoRow(label: "Email", value: speaker.email)
                }

                if !speaker.social.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    infoRow(label: "Links", value: speaker.social)
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
        .navigationTitle("Speaker")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { NavBrandLogo() }
    }

    @ViewBuilder
    private func infoRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundColor(.primaryBlue)

            Text(value)
                .font(.subheadline)
                .foregroundColor(.secondaryText)
        }
    }
}

// MARK: - Photo helper

struct SpeakerPhoto: View {
    let photoFilename: String
    let size: CGFloat

    var body: some View {
        let assetName = photoFilename
            .replacingOccurrences(of: ".png", with: "")
            .replacingOccurrences(of: ".jpg", with: "")
            .replacingOccurrences(of: ".jpeg", with: "")

        // If the image doesn’t exist yet, show a neat placeholder
        Group {
            if UIImage(named: assetName) != nil {
                Image(assetName)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    Circle().fill(Color.dividerGrey.opacity(0.55))
                    Image(systemName: "person.fill")
                        .font(.system(size: size * 0.35, weight: .semibold))
                        .foregroundColor(.secondaryText)
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(
            Circle().stroke(Color.dividerGrey, lineWidth: 1)
        )
    }
}

// MARK: - Nav Bar Logo (LOCKED SPEC)

struct NavBrandLogo: ToolbarContent {
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
}

// MARK: - Error View

struct SpeakerErrorView: View {
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
