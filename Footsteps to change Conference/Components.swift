import SwiftUI

// MARK: - Home Hub Tile
struct HubTile: View {
    let title: String
    let icon: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(.primaryBlue)

            Text(title)
                .font(.headline)
                .foregroundColor(.primaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 6)
        }
        .frame(maxWidth: .infinity, minHeight: 110)
        .background(Color.cardBackground)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.dividerGrey, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
    }
}

// MARK: - Navigation Bar Brand Logo (LOCKED SPEC)
struct NavBrandLogo: ToolbarContent {
    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Image("conferenceLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .padding(2)
                .background(Color.cardBackground)
                .cornerRadius(2)
                .overlay(
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(Color.dividerGrey, lineWidth: 1)
                )
                .accessibilityHidden(true)
        }
    }
}

// MARK: - Reusable Placeholder Page (for pages not built yet)
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
                    .fixedSize(horizontal: false, vertical: true)

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
        .toolbar { NavBrandLogo() }
    }
}

