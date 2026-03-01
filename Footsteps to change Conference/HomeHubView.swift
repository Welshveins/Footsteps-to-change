import SwiftUI

struct HomeHubView: View {

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // MARK: – Welcome / Header (polished)
                    VStack(alignment: .leading, spacing: 6) {

                        Text("Footsteps to Change")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.primaryBlue)

                        Text("Conference 2026")
                            .font(.title3)
                            .foregroundColor(.secondaryText)

                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        LinearGradient(
                            colors: [
                                Color.primaryBlue.opacity(0.12),
                                Color.primaryBlue.opacity(0.04)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(24)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.dividerGrey, lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.04), radius: 18, x: 0, y: 10)
                    .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
                    .padding(.horizontal)

                    // MARK: – Welcome card (links to full Welcome page)
                    NavigationLink(destination: WelcomeView()) {
                        WelcomeCardPreview()
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)

                    // MARK: – Home Hub Tiles
                    LazyVGrid(columns: columns, spacing: 16) {

                        NavigationLink {
                            ProgrammeView()
                        } label: {
                            HubTile(title: "Programme", icon: "calendar")
                        }

                        NavigationLink {
                            SpeakersView()
                        } label: {
                            HubTile(title: "Speakers", icon: "person.2")
                        }

                        NavigationLink {
                            VenueView()
                        } label: {
                            HubTile(title: "Venue", icon: "map")
                        }

                        NavigationLink {
                            ParkingMapView()
                        } label: {
                            HubTile(title: "Parking", icon: "car")
                        }

                        NavigationLink {
                            FloorPlanView()
                        } label: {
                            HubTile(title: "Floor Plan", icon: "square.grid.2x2")
                        }

                        NavigationLink {
                            FeedbackView()
                        } label: {
                            HubTile(title: "Feedback", icon: "checkmark.bubble")
                        }

                        NavigationLink {
                            CertificateView()
                        } label: {
                            HubTile(title: "Certificate", icon: "doc.text")
                        }

                        NavigationLink {
                            UpcomingEventsView()
                        } label: {
                            HubTile(title: "Teaching Events", icon: "graduationcap")
                        }

                        NavigationLink {
                            AbstractsView()
                        } label: {
                            HubTile(title: "Abstracts", icon: "doc.text.magnifyingglass")
                        }
                        NavigationLink {
                            SponsorsView()
                        } label: {
                            HubTile(title: "Sponsors", icon: "star")
                        }                    }
                    .padding(.horizontal)

                    Spacer(minLength: 24)
                }
                .padding(.top, 16)
            }
            .background(Color.appBackground)
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                NavBrandLogo()
            }
        }
    }
}

// MARK: - Welcome Card Preview (keep OUTSIDE HomeHubView)

struct WelcomeCardPreview: View {
    var body: some View {
        VStack(spacing: 10) {

            // Title — bold, centred, same feel as hub tiles
            Text("Welcome")
                .font(.system(size: 20, weight: .bold))   // slightly bigger than .headline
                .foregroundColor(.primaryBlue)
                .multilineTextAlignment(.center)

            // Supporting text
            Text("Welcome to Warwick University — and to Footsteps to Change 2026.")
                .font(.subheadline)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            // CTA
            Text("Read welcome →")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.primaryBlue)
                .padding(.top, 4)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.cardBackground)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.dividerGrey, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
    }
}
