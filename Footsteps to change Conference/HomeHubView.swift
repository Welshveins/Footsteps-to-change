import SwiftUI

// MARK: - Design System (Locked-in colours)
extension Color {
    static let appBackground = Color(red: 238/255, green: 243/255, blue: 250/255) // #EEF3FA
    static let cardBackground = Color.white
    static let primaryBlue = Color(red: 31/255, green: 111/255, blue: 214/255)   // #1F6FD6
    static let accentOrange = Color(red: 242/255, green: 140/255, blue: 27/255)  // #F28C1B
    static let primaryText = Color(red: 26/255, green: 26/255, blue: 26/255)     // #1A1A1A
    static let secondaryText = Color(red: 95/255, green: 107/255, blue: 122/255) // #5F6B7A
    static let dividerGrey = Color(red: 220/255, green: 227/255, blue: 237/255)  // #DCE3ED
}

// MARK: - Home Hub View
struct HomeHubView: View {
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // Add to Home Screen prompt (first visit friendly)
                    InstallPromptCard()

                    LazyVGrid(columns: columns, spacing: 16) {

                        NavigationLink(destination: ProgrammeView()) {
                            HubTile(title: "Programme", icon: "calendar")
                        }
                        .buttonStyle(.plain)

                        NavigationLink(destination: SpeakersView()) {
                            HubTile(title: "Speakers", icon: "person.2")
                        }
                        .buttonStyle(.plain)

                        NavigationLink(destination: FloorPlanView()) {
                            HubTile(title: "Floor Plan", icon: "map")
                        }
                        .buttonStyle(.plain)

                        NavigationLink(destination: VenueView()) {
                            HubTile(title: "Venue", icon: "location")
                        }
                        .buttonStyle(.plain)

                        NavigationLink(destination: FeedbackView()) {
                            HubTile(title: "Feedback & Certificate", icon: "doc.text", emphasised: true)
                        }
                        .buttonStyle(.plain)

                        NavigationLink(destination: SponsorsView()) {
                            HubTile(title: "Sponsors", icon: "star")
                        }
                        .buttonStyle(.plain)

                        NavigationLink(destination: ThankYouView()) {
                            HubTile(title: "Thank You", icon: "heart")
                        }
                        .buttonStyle(.plain)

                        NavigationLink(destination: UpcomingEventsView()) {
                            HubTile(title: "Upcoming Events", icon: "graduationcap")
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("Conference Hub")
            .toolbarBackground(Color.appBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .background(Color.appBackground)
        }
    }
}

// MARK: - Hub Tile
struct HubTile: View {
    let title: String
    let icon: String
    var emphasised: Bool = false

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(emphasised ? .accentOrange : .primaryBlue)

            Text(title)
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.primaryText)
        }
        .frame(maxWidth: .infinity, minHeight: 120)
        .padding(.vertical, 4)
        .background(Color.cardBackground)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.dividerGrey, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Install Prompt Card (simple prototype)
struct InstallPromptCard: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "arrow.down.circle")
                .font(.system(size: 28))
                .foregroundColor(.accentOrange)

            VStack(alignment: .leading, spacing: 4) {
                Text("Add to Home Screen")
                    .font(.headline)
                    .foregroundColor(.primaryText)

                Text("For one-tap access all day at the conference")
                    .font(.subheadline)
                    .foregroundColor(.secondaryText)
            }

            Spacer()
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.dividerGrey, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
    }
}

// MARK: - On-brand placeholder page (so every destination looks polished)
struct PlaceholderPage: View {
    let title: String
    let message: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
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
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Destination views (now styled placeholders)


struct FloorPlanView: View {
    var body: some View {
        PlaceholderPage(
            title: "Floor Plan",
            message: "Venue floor plan will appear here. This will be a one-tap, pinch-to-zoom map."
        )
    }
}

struct VenueView: View {
    var body: some View {
        PlaceholderPage(
            title: "Venue & Directions",
            message: "Address, travel guidance, and an 'Open in Maps' button will live here."
        )
    }
}

struct FeedbackView: View {
    var body: some View {
        PlaceholderPage(
            title: "Feedback",
            message: "Attendees complete feedback here. Certificate unlocks only after submission."
        )
    }
}

struct SponsorsView: View {
    var body: some View {
        PlaceholderPage(
            title: "Sponsors",
            message: "Sponsor logos and adverts will appear here."
        )
    }
}

struct ThankYouView: View {
    var body: some View {
        PlaceholderPage(
            title: "Thank You",
            message: "A celebratory retirement acknowledgement page (not memorial)."
        )
    }
}

struct UpcomingEventsView: View {
    var body: some View {
        PlaceholderPage(
            title: "Upcoming Teaching Events",
            message: "Future organiser-run training days with dates and venues will be listed here."
        )
    }
}

#Preview {
    HomeHubView()
}
