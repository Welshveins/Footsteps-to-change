import SwiftUI

// MARK: - Premium card styling (Pro Move #1)
extension View {
    /// Consistent “studio” card depth + rounded style.
    func premiumCard(cornerRadius: CGFloat = 20) -> some View {
        self
            .background(Color.cardBackground)
            .cornerRadius(cornerRadius)
            .shadow(color: .black.opacity(0.04), radius: 20, x: 0, y: 10)
            .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Press feedback (Pro Move #3)
struct PressableCard: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

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
        .premiumCard(cornerRadius: 22) // upgraded depth + roundness
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.dividerGrey, lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 22)) // better tap target
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
            .premiumCard(cornerRadius: 22) // upgraded depth + roundness
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(Color.dividerGrey, lineWidth: 1)
            )
            .padding()
        }
        .background(Color.appBackground)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { NavBrandLogo() }
    }
}
