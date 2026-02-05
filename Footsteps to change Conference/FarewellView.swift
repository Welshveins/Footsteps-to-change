import SwiftUI
import Combine

// MARK: - Models (farewell.json)

struct FarewellPayload: Codable {
    let speakers: [FarewellPerson]
}

struct FarewellPerson: Codable {
    let name: String
    let credentials: String?
    let organisation: String?
    let role: String?
    let bio: String
    let citation_short: String?
    let website: String?
}

// MARK: - Store

final class FarewellStore: ObservableObject {
    @Published var person: FarewellPerson?
    @Published var loadError: String?

    func loadFromBundle() {
        guard let url = Bundle.main.url(forResource: "farewell", withExtension: "json") else {
            DispatchQueue.main.async {
                self.loadError = """
                farewell.json not found.

                Check:
                • File name is exactly farewell.json
                • Added to Target Membership
                • Listed in Build Phases → Copy Bundle Resources
                """
            }
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let data = try Data(contentsOf: url)
                let decoded = try JSONDecoder().decode(FarewellPayload.self, from: data)
                DispatchQueue.main.async {
                    self.person = decoded.speakers.first
                    self.loadError = decoded.speakers.first == nil ? "farewell.json loaded but contains no entries." : nil
                }
            } catch {
                DispatchQueue.main.async {
                    self.loadError = "Failed to load farewell.json: \(error.localizedDescription)"
                }
            }
        }
    }
}

// MARK: - Farewell View

struct FarewellView: View {
    @StateObject private var store = FarewellStore()
    @Environment(\.openURL) private var openURL

    // Photo asset you said you will add
    private let photoAssetName = "francis_cole"

    var body: some View {
        Group {
            if let err = store.loadError {
                PlaceholderPage(title: "Farewell", message: err)

            } else if let p = store.person {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {

                        // Photo (centered)
                        if UIImage(named: photoAssetName) != nil {
                            HStack {
                                Spacer()
                                Image(photoAssetName)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle().stroke(Color.dividerGrey, lineWidth: 1)
                                    )
                                Spacer()
                            }
                            .padding(.top, 4)
                        }

                        // Title
                        Text("Farewell")
                            .font(.largeTitle.bold())
                            .foregroundColor(.primaryBlue)
                            .frame(maxWidth: .infinity, alignment: .center)

                        // Name / role card
                        card {
                            Text(p.name)
                                .font(.title2.bold())
                                .foregroundColor(.primaryText)

                            if let role = p.role, !role.isEmpty {
                                Text(role)
                                    .font(.headline)
                                    .foregroundColor(.primaryBlue)
                            }

                            if let org = p.organisation, !org.isEmpty {
                                Text(org)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(.secondaryText)
                            }

                            if let cred = p.credentials, !cred.isEmpty {
                                Text(cred)
                                    .font(.subheadline)
                                    .foregroundColor(.secondaryText)
                            }
                        }

                        // Main message
                        card {
                            Text(p.bio)
                                .font(.body)
                                .foregroundColor(.primaryText)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        // Website link (optional)
                        if let site = p.website, !site.isEmpty {
                            Button {
                                openLink(site)
                            } label: {
                                HStack {
                                    Image(systemName: "link")
                                    Text("Visit website")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .bold))
                                }
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.primaryBlue)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 14)
                                .background(Color.primaryBlue.opacity(0.10))
                                .cornerRadius(14)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal)
                        }

                        Spacer(minLength: 24)
                    }
                    .padding(.top, 8)
                }
                .background(Color.appBackground)

            } else {
                PlaceholderPage(title: "Farewell", message: "Loading…")
            }
        }
        .navigationTitle("Farewell")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { NavBrandLogo() }
        .onAppear { store.loadFromBundle() }
    }

    // MARK: - Helpers

    @ViewBuilder
    private func card(@ViewBuilder _ content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            content()
        }
        .padding(14)
        .background(Color.cardBackground)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.dividerGrey, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
        .padding(.horizontal)
    }

    private func openLink(_ s: String) {
        let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: trimmed) else { return }
        openURL(url)
    }
}
