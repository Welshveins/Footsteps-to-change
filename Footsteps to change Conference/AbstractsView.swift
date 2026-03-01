import SwiftUI

// MARK: - Abstracts View (light list, full detail on tap, robust bundle loading)

struct AbstractsView: View {

    @State private var abstracts: [AbstractItem] = []
    @State private var loadError: String? = nil
    @State private var debugBundleJSON: [String] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                Text("Abstracts")
                    .font(.largeTitle.bold())
                    .foregroundColor(.primaryBlue)

                Text("Tap an abstract to read the full details.")
                    .foregroundColor(.secondaryText)

                if let loadError {
                    errorCard(loadError)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(abstracts) { item in
                            NavigationLink {
                                AbstractDetailView(item: item)
                            } label: {
                                AbstractRowCard(item: item)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Spacer(minLength: 24)
            }
            .padding()
        }
        .background(Color.appBackground)
        .navigationTitle("Abstracts")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { NavBrandLogo() }
        .onAppear(perform: loadAbstracts)
    }

    // MARK: - Load

    private func loadAbstracts() {
        loadError = nil
        abstracts = []

        // Helpful diagnostics: list JSON files visible in the bundle.
        debugBundleJSON = listAllJSONFileNames()

        // Try to find the abstracts JSON robustly.
        guard let url = findAbstractsJSONURL() else {
            loadError =
            """
            Could not find the abstracts JSON file in the app bundle.

            Things to check:
            • The file is included in Copy Bundle Resources ✅ (you’ve done this)
            • The filename may not be exactly 'abstracts.json'
            • It may be inside a bundle subfolder (e.g. Data/)

            JSON files I can currently see in your bundle:
            \(debugBundleJSON.isEmpty ? "— none found —" : debugBundleJSON.joined(separator: "\n"))
            """
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(AbstractsContainer.self, from: data)

            // Sort by title A–Z (remove if you want supplied order)
            abstracts = decoded.items.sorted {
                $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
            }

        } catch {
            loadError =
            """
            Found the JSON file, but decoding failed.

            File: \(url.lastPathComponent)

            Error:
            \(error.localizedDescription)
            """
        }
    }

    /// Finds abstracts.json even if it’s in a bundle subdirectory or named slightly differently.
    private func findAbstractsJSONURL() -> URL? {

        // 1) Try the simplest exact match first (root).
        if let u = Bundle.main.url(forResource: "abstracts", withExtension: "json") { return u }

        // 2) Try common subdirectories used in this project.
        let subdirs: [String?] = [nil, "Data", "data", "JSON", "Json", "Resources"]

        // 3) If you renamed the file, try common variants.
        let nameCandidates = [
            "abstracts",
            "Abstracts",
            "ABSTRACTS",
            "abstracts_final",
            "abstracts_FINAL",
            "Abstracts_FINAL",
            "abstracts2026",
            "abstracts_2026"
        ]

        for sub in subdirs {
            for name in nameCandidates {
                if let u = Bundle.main.url(forResource: name, withExtension: "json", subdirectory: sub) {
                    return u
                }
            }
        }

        // 4) Last resort: scan all JSON files and pick the one whose filename contains "abstract".
        let allJSON = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil) ?? []
        if let match = allJSON.first(where: { $0.lastPathComponent.lowercased().contains("abstract") }) {
            return match
        }

        // Also scan common subdirectories.
        for sub in ["Data", "data", "JSON", "Json", "Resources"] {
            let subJSON = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: sub) ?? []
            if let match = subJSON.first(where: { $0.lastPathComponent.lowercased().contains("abstract") }) {
                return match
            }
        }

        return nil
    }

    private func listAllJSONFileNames() -> [String] {
        var results: [String] = []

        let roots = (Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil) ?? [])
            .map { $0.lastPathComponent }

        results.append(contentsOf: roots)

        for sub in ["Data", "data", "JSON", "Json", "Resources"] {
            let subs = (Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: sub) ?? [])
                .map { "\(sub)/\($0.lastPathComponent)" }
            results.append(contentsOf: subs)
        }

        // De-dupe + sort
        return Array(Set(results)).sorted()
    }

    // MARK: - UI Helpers

    private func errorCard(_ message: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Couldn’t load abstracts")
                .font(.headline)
                .foregroundColor(.primaryText)

            Text(message)
                .font(.subheadline)
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
}

// MARK: - Row Card (lightweight: title + authors + aim)

struct AbstractRowCard: View {
    let item: AbstractItem

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            Text(item.title)
                .font(.headline)
                .foregroundColor(.primaryText)
                .fixedSize(horizontal: false, vertical: true)

            if !item.authors.isEmpty {
                Text(item.authorsLine)
                    .font(.subheadline)
                    .foregroundColor(.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let aim = item.aimPreview, !aim.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Aim")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.primaryBlue)

                    Text(aim)
                        .font(.subheadline)
                        .foregroundColor(.secondaryText)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            HStack {
                Text("Open →")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.primaryBlue)
                Spacer()
            }
            .padding(.top, 2)

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

// MARK: - Detail View (full content)

struct AbstractDetailView: View {
    let item: AbstractItem

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {

                Text(item.title)
                    .font(.title2.bold())
                    .foregroundColor(.primaryBlue)
                    .fixedSize(horizontal: false, vertical: true)

                if !item.authors.isEmpty {
                    Text(item.authorsLine)
                        .font(.headline)
                        .foregroundColor(.primaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if let sections = item.sections, sections.hasAnyContent {
                    if let background = sections.background, !background.trimmed.isEmpty {
                        section("Background", background)
                    }
                    if let aim = sections.aim, !aim.trimmed.isEmpty {
                        section("Aim", aim)
                    }
                    if let methods = sections.methods, !methods.trimmed.isEmpty {
                        section("Methods", methods)
                    }
                    if let results = sections.results, !results.trimmed.isEmpty {
                        section("Results", results)
                    }
                    if let conclusion = sections.conclusion, !conclusion.trimmed.isEmpty {
                        section("Conclusion", conclusion)
                    }
                    if let abs = sections.abstract, !abs.trimmed.isEmpty {
                        section("Abstract", abs)
                    }
                } else if let abstractText = item.abstractText, !abstractText.trimmed.isEmpty {
                    section("Abstract", abstractText)
                } else if let raw = item.rawText, !raw.trimmed.isEmpty {
                    section("Text", raw)
                } else {
                    Text("No abstract text available.")
                        .foregroundColor(.secondaryText)
                }

                Spacer(minLength: 24)
            }
            .padding()
        }
        .background(Color.appBackground)
        .navigationTitle("Abstract")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { NavBrandLogo() }
    }

    private func section(_ title: String, _ body: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primaryText)

            Text(body)
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
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Models (match your JSON)

struct AbstractsContainer: Decodable {
    let schemaVersion: String?
    let generatedAt: String?
    let items: [AbstractItem]
}

struct AbstractItem: Identifiable, Decodable {
    let id: String
    let title: String
    let authors: [String]
    let abstractText: String?
    let rawText: String?
    let sections: AbstractSections?

    var authorsLine: String {
        authors.joined(separator: ", ")
    }

    var aimPreview: String? {
        if let a = sections?.aim, !a.trimmed.isEmpty { return a.trimmed }

        // If no explicit aim, create a short preview from abstractText/rawText.
        if let abs = abstractText, !abs.trimmed.isEmpty {
            if let extracted = abs.extractBlock(afterHeading: "AIM") { return extracted }
            return abs.trimmed.firstParagraphOrFirstLine(limit: 220)
        }

        if let raw = rawText, !raw.trimmed.isEmpty {
            return raw.trimmed.firstParagraphOrFirstLine(limit: 220)
        }

        return nil
    }
}

struct AbstractSections: Decodable {
    let background: String?
    let aim: String?
    let methods: String?
    let results: String?
    let conclusion: String?
    let abstract: String?

    var hasAnyContent: Bool {
        [background, aim, methods, results, conclusion, abstract]
            .contains { ($0?.trimmed.isEmpty == false) }
    }
}

// MARK: - String helpers

private extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }

    func firstParagraphOrFirstLine(limit: Int) -> String {
        let cleaned = self
            .replacingOccurrences(of: "\r", with: "\n")
            .replacingOccurrences(of: "\n\n\n", with: "\n\n")
            .trimmed

        let first = cleaned.components(separatedBy: "\n\n").first ?? cleaned
        if first.count <= limit { return first }
        let idx = first.index(first.startIndex, offsetBy: limit)
        return String(first[..<idx]).trimmed + "…"
    }

    func extractBlock(afterHeading heading: String) -> String? {
        let text = self.replacingOccurrences(of: "\r", with: "\n")
        let patterns = ["\n\(heading)\n", "\(heading)\n"]

        guard let rangeStart = patterns.compactMap({ text.range(of: $0, options: .caseInsensitive) }).first else {
            return nil
        }

        let after = text[rangeStart.upperBound...]
        let afterString = String(after).trimmed
        guard !afterString.isEmpty else { return nil }

        let lines = afterString.components(separatedBy: "\n")
        var collected: [String] = []

        for line in lines {
            let t = line.trimmed
            if t.isEmpty { break }

            if t == t.uppercased(),
               t.count <= 18,
               t.allSatisfy({ $0.isLetter || $0 == " " || $0 == "-" }) {
                break
            }

            collected.append(line)
        }

        let block = collected.joined(separator: "\n").trimmed
        return block.isEmpty ? nil : block.firstParagraphOrFirstLine(limit: 260)
    }
}
