import SwiftUI

// MARK: - Sponsors View (loads 2 sponsor JSON files + shows logos + blurb, alphabetical)

struct SponsorsView: View {

    @State private var sponsors: [Sponsor] = []
    @State private var loadError: String? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                Text("Sponsors")
                    .font(.largeTitle.bold())
                    .foregroundColor(.primaryBlue)

                Text("Thank you to our sponsors for supporting Footsteps to Change Conference 2026.")
                    .foregroundColor(.secondaryText)

                if let loadError {
                    errorCard(loadError)
                } else {
                    ForEach(sponsors) { sponsor in
                        sponsorCard(sponsor)
                    }
                }

                Spacer(minLength: 24)
            }
            .padding()
        }
        .background(Color.appBackground)
        .navigationTitle("Sponsors")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { NavBrandLogo() }
        .onAppear(perform: loadSponsors)
    }

    // MARK: - UI

    private func sponsorCard(_ sponsor: Sponsor) -> some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack(alignment: .center, spacing: 12) {

                // Logo box
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.cardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.dividerGrey, lineWidth: 1)
                        )

                    Image(sponsor.logoAssetName)
                        .resizable()
                        .scaledToFit()
                        .padding(10)
                }
                .frame(width: 86, height: 86)

                VStack(alignment: .leading, spacing: 4) {
                    Text(sponsor.name)
                        .font(.headline)
                        .foregroundColor(.primaryText)

                    if let subtitle = sponsor.subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Spacer()
            }

            Text(sponsor.blurb)
                .font(.body)
                .foregroundColor(.secondaryText)
                .fixedSize(horizontal: false, vertical: true)

        }
        .padding(14)
        .background(Color.cardBackground)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.dividerGrey, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
    }

    private func errorCard(_ message: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Couldn’t load sponsors")
                .font(.headline)
                .foregroundColor(.primaryText)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondaryText)
                .fixedSize(horizontal: false, vertical: true)

            Text("Check: file names (case-sensitive), Copy Bundle Resources, and whether the files are inside a folder.")
                .font(.footnote)
                .foregroundColor(.secondaryText)
        }
        .padding(14)
        .background(Color.cardBackground)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.dividerGrey, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
    }

    // MARK: - Loading

    private func loadSponsors() {

        loadError = nil

        // We try multiple possible resource names (case/format variants) so it doesn’t break
        // if the organiser saved the files with different names.
        let candidates: [(resource: String, ext: String, logoCandidates: [String])] = [
            // BPS
            ("BPS", "json", ["BPS_1024", "BPS_1024.png"]),
            ("bps", "json", ["BPS_1024", "BPS_1024.png"]),
            ("BritishPainSociety", "json", ["BPS_1024", "BPS_1024.png"]),
            ("the_british_pain_society", "json", ["BPS_1024", "BPS_1024.png"]),

            // Pure Unity Health
            ("PureUnityHealth", "json", ["PureUnityHealth_1024", "PureUnityHealth_1024.png"]),
            ("pureunityhealth", "json", ["PureUnityHealth_1024", "PureUnityHealth_1024.png"]),
            ("pure_unity_health", "json", ["PureUnityHealth_1024", "PureUnityHealth_1024.png"]),
            ("Pure_Unity_Health", "json", ["PureUnityHealth_1024", "PureUnityHealth_1024.png"])
        ]

        var byName: [String: Sponsor] = [:]
        var foundAnyFile = false

        for c in candidates {
            if let url = Bundle.main.url(forResource: c.resource, withExtension: c.ext) {
                foundAnyFile = true
                do {
                    let data = try Data(contentsOf: url)
                    let payload = try JSONDecoder().decode(SponsorPayload.self, from: data)
                    let sponsor = makeSponsor(from: payload, logoCandidates: c.logoCandidates)
                    byName[sponsor.name] = sponsor
                } catch {
                    loadError = "Failed to decode \(c.resource).\(c.ext): \(error.localizedDescription)"
                    sponsors = []
                    return
                }
            }
        }

        if byName.isEmpty {
            loadError = foundAnyFile
                ? "Sponsor files were found, but none decoded into sponsor content. Check the JSON structure."
                : "No sponsor JSON files found in the app bundle. Ensure the JSON filenames match what the app is looking for (case-sensitive), and they are included in Copy Bundle Resources."
            sponsors = []
            return
        }

        sponsors = Array(byName.values).sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
    }

    private func makeSponsor(from payload: SponsorPayload, logoCandidates: [String]) -> Sponsor {

        // Try to resolve the logo asset name:
        // - Image("PureUnityHealth_1024.png") usually works
        // - If not, Image("PureUnityHealth_1024") is also common (some people omit extension)
        let resolvedLogo: String = {
            for candidate in logoCandidates {
                if UIImage(named: candidate) != nil {
                    return candidate
                }
            }

            // Fallbacks using your known asset names
            if payload.organisation.abbreviation?.uppercased() == "BPS" {
                return UIImage(named: "BPS_1024.png") != nil ? "BPS_1024.png" : "BPS_1024"
            } else {
                return UIImage(named: "PureUnityHealth_1024.png") != nil ? "PureUnityHealth_1024.png" : "PureUnityHealth_1024"
            }
        }()

        // Subtitle (nice short line under name)
        let subtitle: String? = {
            if let abbr = payload.organisation.abbreviation, !abbr.isEmpty {
                return abbr
            }
            if let type = payload.organisation.type, !type.isEmpty {
                return type
            }
            return nil
        }()

        // Blurb (clean “overview + mission focus” style)
        let blurb: String = {
            var parts: [String] = []
            if let overview = payload.organisation.overview, !overview.isEmpty {
                parts.append(overview.trimmingCharacters(in: .whitespacesAndNewlines))
            }
            if let missionFocus = payload.organisation.missionFocus, !missionFocus.isEmpty {
                parts.append(missionFocus.trimmingCharacters(in: .whitespacesAndNewlines))
            }
            if parts.isEmpty {
                // BPS uses different keys; pull a few from mission/approach
                if let vision = payload.missionAndVision?.vision, !vision.isEmpty {
                    parts.append(vision.trimmingCharacters(in: .whitespacesAndNewlines))
                }
                if let collab = payload.approach?.collaboration, !collab.isEmpty {
                    parts.append(collab.trimmingCharacters(in: .whitespacesAndNewlines))
                }
                if let partnerships = payload.approach?.partnerships, !partnerships.isEmpty {
                    parts.append(partnerships.trimmingCharacters(in: .whitespacesAndNewlines))
                }
            }
            return parts.joined(separator: "\n\n")
        }()

        return Sponsor(
            id: payload.organisation.name,
            name: payload.organisation.name,
            subtitle: subtitle,
            blurb: blurb,
            logoAssetName: resolvedLogo
        )
    }
}

// MARK: - Models

struct Sponsor: Identifiable {
    let id: String
    let name: String
    let subtitle: String?
    let blurb: String
    let logoAssetName: String
}

struct SponsorPayload: Decodable {
    let organisation: SponsorOrganisation
    let missionAndVision: MissionAndVision?
    let approach: SponsorApproach?
}

struct SponsorOrganisation: Decodable {
    let name: String
    let abbreviation: String?
    let scope: String?
    let type: String?
    let overview: String?
    let establishedPartnership: Int?
    let missionFocus: String?
}

struct MissionAndVision: Decodable {
    let vision: String?
    let coreFocus: [String]?
}

struct SponsorApproach: Decodable {
    let collaboration: String?
    let partnerships: String?
    let equity: String?
}
