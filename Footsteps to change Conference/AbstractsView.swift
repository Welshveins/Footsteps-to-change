import SwiftUI

// MARK: - Models (MATCHES ORGANISER JSON EXACTLY)

struct AbstractsPayload: Codable {
    let schemaVersion: String?
    let generatedAt: String?
    let items: [AbstractItem]
}

struct AbstractItem: Codable, Identifiable {
    let id: String
    let sourceFile: String?
    let title: String
    let authors: [String]
    let affiliations: [String]
    let contactEmails: [String]
    let topic: String?
    let sections: [String: String]
    let keywords: [String]
    let references: [String]
    let rawText: String?
    let abstractText: String?
    let additionalContributors: [String]?
}

// MARK: - View

struct AbstractsView: View {

    @State private var abstracts: [AbstractItem] = []
    @State private var loadError: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                Text("Abstracts")
                    .font(.largeTitle.bold())
                    .foregroundColor(.primaryBlue)

                if let loadError {
                    Text(loadError)
                        .foregroundColor(.red)
                        .padding(.top, 8)
                }

                ForEach(abstracts) { abstract in
                    AbstractCard(abstract: abstract)
                }

                Spacer(minLength: 24)
            }
            .padding()
        }
        .background(Color.appBackground)
        .navigationTitle("Abstracts")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { NavBrandLogo() }
        .onAppear {
            loadAbstracts()
        }
    }

    // MARK: - Load JSON

    private func loadAbstracts() {

        loadError = nil

        // Try common name variations safely
        let candidates: [(String, String)] = [
            ("abstracts", "json"),
            ("Abstracts", "json"),
            ("abstracts", "JSON"),
            ("Abstracts", "JSON")
        ]

        let foundURL = candidates
            .compactMap { Bundle.main.url(forResource: $0.0, withExtension: $0.1) }
            .first

        guard let url = foundURL else {
            loadError = "abstracts.json not found in app bundle. Check Build Phases → Copy Bundle Resources."
            abstracts = []
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let payload = try JSONDecoder().decode(AbstractsPayload.self, from: data)
            abstracts = payload.items
        } catch {
            loadError = "Failed to decode abstracts.json: \(error.localizedDescription)"
            abstracts = []
        }
    }
}

// MARK: - Abstract Card

struct AbstractCard: View {

    let abstract: AbstractItem

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            Text(abstract.title)
                .font(.headline)
                .foregroundColor(.primaryText)

            if !abstract.authors.isEmpty {
                Text(abstract.authors.joined(separator: ", "))
                    .font(.subheadline)
                    .foregroundColor(.secondaryText)
            }

            Divider()

            // Prefer structured sections if available
            if !abstract.sections.isEmpty {

                ForEach(abstract.sections.keys.sorted(), id: \.self) { key in
                    if let value = abstract.sections[key] {

                        Text(key.uppercased())
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.primaryBlue)

                        Text(value)
                            .font(.body)
                            .foregroundColor(.primaryText)
                    }
                }

            } else if let text = abstract.abstractText {

                Text(text)
                    .font(.body)
                    .foregroundColor(.primaryText)
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
