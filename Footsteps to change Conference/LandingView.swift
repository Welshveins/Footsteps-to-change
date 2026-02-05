import SwiftUI

struct LandingView: View {

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 18) {
                Spacer()

                // Hero logo
                Image("conferenceLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 260)
                    .padding(.bottom, 6)

                Text("Footsteps to Change")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.primaryText)
                    .multilineTextAlignment(.center)

                Text("Conference 2026")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.primaryBlue)
                    .multilineTextAlignment(.center)

                // Add to Home Screen guidance (always visible, but subtle)
                LandingInstallHint()
                    .padding(.top, 10)
                    .padding(.horizontal)

                Spacer()

                NavigationLink {
                    HomeHubView()
                } label: {
                    Text("ENTER")
                        .font(.headline.weight(.bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.primaryBlue)
                        .cornerRadius(18)
                        .shadow(color: .black.opacity(0.12), radius: 6, x: 0, y: 2)
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
        }
    }
}

// MARK: - Install hint (non-blocking)

struct LandingInstallHint: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "arrow.down.circle")
                .font(.system(size: 22))
                .foregroundColor(.accentOrange)

            Text("Add to Home Screen for one-tap access during the conference")
                .font(.subheadline)
                .foregroundColor(.secondaryText)

            Spacer()
        }
        .padding(14)
        .background(Color.cardBackground)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.dividerGrey, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    NavigationStack {
        LandingView()
    }
}
