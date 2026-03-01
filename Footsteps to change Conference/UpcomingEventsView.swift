import SwiftUI
import Combine

// MARK: - Models (matches your JSON)

struct TeachingEventsPayload: Codable {
    let events: [TeachingEvent]
}

struct TeachingEvent: Codable, Identifiable {
    let id: String
    let title: String
    let date: String          // "YYYY-MM-DD"
    let venue: String
    let city: String
    let details: String
    let link: String
}

// MARK: - Store

@MainActor
final class TeachingEventsStore: ObservableObject {

    @Published var events: [TeachingEvent] = []
    @Published var loadError: String? = nil

    func loadFromBundle() {
        guard let url = Bundle.main.url(forResource: "teaching_events", withExtension: "json") else {
            loadError = "teaching_events.json not found. Check file name + Target Membership."
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(TeachingEventsPayload.self, from: data)
            self.events = decoded.events
            self.loadError = nil
        } catch {
            self.loadError = "Failed to load teaching_events.json: \(error.localizedDescription)"
        }
    }
}

// MARK: - View

struct UpcomingEventsView: View {

    @StateObject private var store = TeachingEventsStore()
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                Text("Teaching Events")
                    .font(.largeTitle.bold())
                    .foregroundColor(.primaryBlue)

                Text("Upcoming courses and training sessions.")
                    .foregroundColor(.secondaryText)

                if let err = store.loadError {
                    errorCard(err)
                } else {

                    // Cohorts A/B/C (in order)
                    ForEach(["A", "B", "C"], id: \.self) { cohort in
                        let cohortEvents = eventsForCohort(cohort)
                        if !cohortEvents.isEmpty {
                            cohortCard(cohort: cohort, events: cohortEvents)
                        }
                    }

                    // Other (non-cohort) events
                    if !otherEvents.isEmpty {
                        otherSection(events: otherEvents)
                    }
                }

                Spacer(minLength: 24)
            }
            .padding()
        }
        .background(Color.appBackground)
        .navigationTitle("Teaching Events")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { NavBrandLogo() }
        .onAppear { store.loadFromBundle() }
    }

    // MARK: - Grouping logic

    private func eventsForCohort(_ cohort: String) -> [TeachingEvent] {
        let filtered = store.events.filter { $0.cohortKey == cohort }
        return filtered.sorted {
            if $0.sessionNumber != $1.sessionNumber {
                return $0.sessionNumber < $1.sessionNumber   // Session 1,2,3
            }
            return $0.date < $1.date                         // tie-break: soonest first
        }
    }

    private var otherEvents: [TeachingEvent] {
        let filtered = store.events.filter { $0.cohortKey == nil }
        return filtered.sorted { $0.date < $1.date }         // soonest first
    }

    // MARK: - UI

    private func cohortCard(cohort: String, events: [TeachingEvent]) -> some View {
        let bookingLink = events.first? .link ?? events.first?.link ?? ""
        let bookingURL = URL(string: bookingLink)

        return VStack(alignment: .leading, spacing: 12) {

            // Header row
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ten Footsteps – 12 Hour Training Programme")
                        .font(.headline)
                        .foregroundColor(.primaryText)

                    Text("Cohort \(cohort) • Sessions must be attended in order")
                        .font(.subheadline)
                        .foregroundColor(.secondaryText)
                }

                Spacer(minLength: 0)

                Text("Online")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.primaryBlue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.appBackground)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.dividerGrey, lineWidth: 1)
                    )
            }

            // Sessions list (clean rows)
            VStack(spacing: 10) {
                ForEach(events) { event in
                    sessionRow(event: event)
                }
            }
            .padding(.top, 2)

            // Single booking button for the cohort
            if let bookingURL {
                Button {
                    openURL(bookingURL)
                } label: {
                    HStack {
                        Text("Open booking / details")
                            .font(.headline)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.headline.weight(.semibold))
                    }
                    .foregroundColor(.primaryBlue)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 14)
                    .background(Color.appBackground) // light blue feel, on-brand
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.dividerGrey, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            }

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

    private func sessionRow(event: TeachingEvent) -> some View {
        HStack(spacing: 12) {

            // Session badge
            Text("Session \(event.sessionNumber)")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.primaryBlue)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.appBackground)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.dividerGrey, lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(event.formattedDateLong) // e.g. Wed 25 Feb 2026
                    .font(.headline)
                    .foregroundColor(.primaryText)

                // If you want a subtitle line, keep it subtle (uses your JSON details)
                Text(event.details)
                    .font(.subheadline)
                    .foregroundColor(.secondaryText)
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding(.vertical, 6)
    }

    private func otherSection(events: [TeachingEvent]) -> some View {
        VStack(alignment: .leading, spacing: 10) {

            Text("Other events")
                .font(.title3.bold())
                .foregroundColor(.primaryText)

            VStack(spacing: 12) {
                ForEach(events) { event in
                    otherEventCard(event)
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
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
    }

    private func otherEventCard(_ event: TeachingEvent) -> some View {
        VStack(alignment: .leading, spacing: 10) {

            Text(event.title)
                .font(.headline)
                .foregroundColor(.primaryText)

            Text(event.formattedDateLong)
                .font(.subheadline)
                .foregroundColor(.secondaryText)

            Text("\(event.venue) • \(event.city)")
                .font(.subheadline)
                .foregroundColor(.secondaryText)

            if let url = URL(string: event.link) {
                Button {
                    openURL(url)
                } label: {
                    HStack {
                        Text("Open booking / details")
                            .font(.headline)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.headline.weight(.semibold))
                    }
                    .foregroundColor(.primaryBlue)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 14)
                    .background(Color.appBackground)
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.dividerGrey, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(Color.appBackground.opacity(0.35))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.dividerGrey, lineWidth: 1)
        )
    }

    private func errorCard(_ message: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Couldn’t load teaching events")
                .font(.headline)
                .foregroundColor(.primaryText)
            Text(message)
                .foregroundColor(.secondaryText)
        }
        .padding(14)
        .background(Color.cardBackground)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.dividerGrey, lineWidth: 1)
        )
    }
}

// MARK: - Helpers (cohort/session + date formatting)

private extension TeachingEvent {

    /// "A" / "B" / "C" or nil for non-cohort events.
    var cohortKey: String? {
        // Prefer ID pattern: "..._A_s1"
        if let match = id.firstMatch(of: /_([ABC])_s[0-9]+/) {
            return String(match.1)
        }

        // Fallback to title: "(Cohort A, Session 1)"
        if title.contains("Cohort A") { return "A" }
        if title.contains("Cohort B") { return "B" }
        if title.contains("Cohort C") { return "C" }
        return nil
    }

    /// Session number (1/2/3) if present; otherwise 999.
    var sessionNumber: Int {
        if let match = id.firstMatch(of: /_s([0-9]+)/) {
            return Int(match.1) ?? 999
        }
        if let match = title.firstMatch(of: /Session\s+([0-9]+)/) {
            return Int(match.1) ?? 999
        }
        return 999
    }

    var parsedDate: Date? {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_GB")
        f.dateFormat = "yyyy-MM-dd"
        return f.date(from: date)
    }

    var formattedDateLong: String {
        guard let d = parsedDate else { return date }
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_GB")
        f.dateFormat = "EEE d MMM yyyy"
        return f.string(from: d)
    }
}
