import SwiftUI

struct UpcomingEventsView: View {
    var body: some View {
        PlaceholderPage(
            title: "Teaching Events",
            message: "Upcoming organiser-run teaching events will appear here."
        )
        .navigationTitle("Teaching Events")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { NavBrandLogo() }
    }
}
