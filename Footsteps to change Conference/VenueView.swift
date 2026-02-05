import SwiftUI
import Combine

// MARK: - Models (matches getting_there.json)

struct GettingThere: Codable {
    let id: String
    let title: String
    let subtitle: String?
    let updated_for: String?
    let venue: VenueInfo
    let travel: [TravelSection]
    let parking: ParkingInfo
}

struct VenueInfo: Codable {
    let name: String
    let postcode: String
    let notes: [String]?
    let links: [LinkItem]?
}

struct TravelSection: Codable, Identifiable {
    var id: String { mode }
    let mode: String
    let summary: String?
    let details: [String]?
    let links: [LinkItem]?
}

struct ParkingInfo: Codable {
    let summary: String?
    let recommended_car_parks: [String]?
    let accessibility_note: String?
    let links: [LinkItem]?
}

struct LinkItem: Codable, Identifiable {
    var id: String { url }
    let label: String
    let url: String
}

// MARK: - Loader

final class GettingThereStore: ObservableObject {
    @Published var data: GettingThere?
    @Published var loadError: String?

    func loadFromBundle() {
        guard let url = Bundle.main.url(forResource: "getting_there", withExtension: "json") else {
            DispatchQueue.main.async {
                self.loadError = """
                getting_there.json not found.

                Check:
                • File name is exactly getting_there.json
                • Added to Target Membership
                • Listed in Build Phases → Copy Bundle Resources
                """
            }
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let raw = try Data(contentsOf: url)
                let decoded = try JSONDecoder().decode(GettingThere.self, from: raw)
                DispatchQueue.main.async {
                    self.data = decoded
                    self.loadError = nil
                }
            } catch {
                DispatchQueue.main.async {
                    self.loadError = "Failed to load getting_there.json: \(error.localizedDescription)"
                }
            }
        }
    }
}

// MARK: - Venue View

struct VenueView: View {
    @StateObject private var store = GettingThereStore()
    @Environment(\.openURL) private var openURL

    var body: some View {
        Group {
            if let err = store.loadError {
                PlaceholderPage(title: "Venue & Directions", message: err)
            } else if let info = store.data {
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {

                        Text("Venue & Directions")
                            .font(.largeTitle.bold())
                            .foregroundColor(.primaryBlue)
                            .padding(.horizontal)
                            .padding(.top, 8)

                        // Venue
                        card {
                            Text(info.venue.name)
                                .font(.headline)
                                .foregroundColor(.primaryText)

                            Text(info.venue.postcode)
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.secondaryText)

                            if let notes = info.venue.notes {
                                ForEach(notes, id: \.self) { line in
                                    Text(line)
                                        .font(.subheadline)
                                        .foregroundColor(.secondaryText)
                                }
                            }

                            if let links = info.venue.links, !links.isEmpty {
                                linkButtons(links)
                            }
                        }
                        .padding(.horizontal)

                        // Parking
                        card {
                            HStack {
                                Text("Parking")
                                    .font(.headline)
                                    .foregroundColor(.primaryText)

                                Spacer()

                                NavigationLink(destination: ParkingMapView()) {
                                    Text("Open map")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundColor(.primaryBlue)
                                }
                                .buttonStyle(.plain)
                            }

                            if let summary = info.parking.summary, !summary.isEmpty {
                                Text(summary)
                                    .font(.subheadline)
                                    .foregroundColor(.secondaryText)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            if let cps = info.parking.recommended_car_parks, !cps.isEmpty {
                                Text("Recommended car parks")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(.primaryText)
                                    .padding(.top, 4)

                                ForEach(cps, id: \.self) { cp in
                                    Text("• \(cp)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondaryText)
                                }
                            }

                            if let acc = info.parking.accessibility_note, !acc.isEmpty {
                                Text(acc)
                                    .font(.subheadline)
                                    .foregroundColor(.secondaryText)
                                    .padding(.top, 4)
                            }

                            if let links = info.parking.links, !links.isEmpty {
                                linkButtons(links)
                            }
                        }
                        .padding(.horizontal)

                        // Travel sections
                        ForEach(info.travel) { section in
                            card {
                                Text(section.mode)
                                    .font(.headline)
                                    .foregroundColor(.primaryText)

                                if let summary = section.summary, !summary.isEmpty {
                                    Text(summary)
                                        .font(.subheadline)
                                        .foregroundColor(.secondaryText)
                                        .fixedSize(horizontal: false, vertical: true)
                                }

                                if let details = section.details {
                                    ForEach(details, id: \.self) { line in
                                        Text("• \(line)")
                                            .font(.subheadline)
                                            .foregroundColor(.secondaryText)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }

                                if let links = section.links, !links.isEmpty {
                                    linkButtons(links)
                                }
                            }
                            .padding(.horizontal)
                        }

                        Spacer(minLength: 24)
                    }
                }
            } else {
                PlaceholderPage(title: "Venue & Directions", message: "Loading…")
            }
        }
        .background(Color.appBackground)
        .navigationTitle("Venue")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { NavBrandLogo() }
        .onAppear { store.loadFromBundle() }
    }

    // MARK: - UI helpers

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
    }

    @ViewBuilder
    private func linkButtons(_ links: [LinkItem]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(links) { link in
                Button {
                    openLink(link.url)
                } label: {
                    HStack {
                        Image(systemName: "link")
                        Text(link.label)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.primaryBlue)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .background(Color.primaryBlue.opacity(0.10))
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 4)
    }

    private func openLink(_ s: String) {
        let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
        let urlString: String

        if trimmed.hasPrefix("http://") || trimmed.hasPrefix("https://") {
            urlString = trimmed
        } else {
            urlString = "https://\(trimmed)"
        }

        guard let url = URL(string: urlString) else { return }
        openURL(url)
    }
}
