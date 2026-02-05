import SwiftUI

struct FeedbackView: View {

    // This is what gates the certificate page
    @AppStorage("feedbackComplete") private var feedbackComplete: Bool = false

    // Put the organiser’s public MS Forms link here
    private let feedbackURLString = "https://forms.office.com/"   // <- replace with full public link

    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                Text("Feedback")
                    .font(.largeTitle.bold())
                    .foregroundColor(.primaryBlue)

                Text("Please complete the feedback form. Once completed, your Certificate will unlock.")
                    .foregroundColor(.secondaryText)

                // MARK: - Feedback form card
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 10) {
                        Image(systemName: "link")
                            .font(.title3.weight(.semibold))
                            .foregroundColor(.primaryBlue)

                        Text("Feedback form")
                            .font(.headline)
                            .foregroundColor(.primaryText)
                    }

                    Text("Tap below to open the Microsoft Form in your browser.")
                        .foregroundColor(.secondaryText)

                    Button {
                        guard let url = URL(string: feedbackURLString) else { return }
                        openURL(url)
                    } label: {
                        HStack {
                            Text("Open feedback form")
                                .font(.headline)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.headline.weight(.semibold))
                        }
                        .foregroundColor(.primaryBlue)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 14)
                        .background(Color.softBlueCard)
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.dividerGrey, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)

                    Text(feedbackURLString)
                        .font(.footnote)
                        .foregroundColor(.secondaryText)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                .padding(14)
                .background(Color.cardBackground)
                .cornerRadius(18)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.dividerGrey, lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)

                // MARK: - Completion toggle card (single toggle ONLY)
                VStack(alignment: .leading, spacing: 10) {

                    Text("Certificate unlock")
                        .font(.headline)
                        .foregroundColor(.primaryText)

                    Text("Required to unlock your certificate.")
                        .foregroundColor(.secondaryText)

                    // This is the ONLY toggle on the page
                    Toggle(isOn: $feedbackComplete) {
                        Text("I have completed the feedback form")
                            .font(.headline)
                            .foregroundColor(.primaryText)
                    }
                    .tint(.primaryBlue)
                    .padding(12)
                    .background(Color.softBlueCard)          // makes “off” state visible
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.dividerGrey, lineWidth: 1)
                    )
                }
                .padding(14)
                .background(Color.cardBackground)
                .cornerRadius(18)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.dividerGrey, lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)

                Spacer(minLength: 24)
            }
            .padding()
        }
        .background(Color.appBackground)
        .navigationTitle("Feedback")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { NavBrandLogo() }
        .preferredColorScheme(.light) // keeps the app on-brand even if phone is in Dark Mode
    }
}
