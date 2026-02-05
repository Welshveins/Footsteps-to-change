import SwiftUI

struct FloorPlanView: View {
    var body: some View {
        PlaceholderPage(
            title: "Floor Plan",
            message: "Venue floor plan will appear here. Pinch to zoom."
        )
        .navigationTitle("Floor Plan")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { NavBrandLogo() }
    }
}
