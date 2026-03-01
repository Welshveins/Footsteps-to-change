import SwiftUI

struct FeedbackView: View {

    // This is what gates the certificate page
    @AppStorage("feedbackComplete") private var feedbackComplete: Bool = false

    // STEP 1: Public MS Forms URL
    private let feedbackURL = URL(string:
        "https://forms.office.com/Pages/ResponsePage.aspx?id=DQSIkWdsW0yxEjajBLZtrQAAAAAAAAAAAANAAQ_9woZUOVlETzBQT0EwNFRHWE9HTjdOQVhOV1c1US4u"
    )!

    // STEP 3: Sheet state
    @State private var showFeedbackSheet = false

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

                    Text("This form opens securely inside the app.")
                        .foregroundColor(.secondaryText)

                    // STEP 2: Replace openURL with in-app sheet
                    Button {
                        showFeedbackSheet = true
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
                        .background(Color.appBackground) // light blue feel, matches your theme
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.dividerGrey, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)

                    Text(feedbackURL.absoluteString)
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

                    Toggle(isOn: $feedbackComplete) {
                        Text("I confirm I have submitted the feedback form")
                            .font(.headline)
                            .foregroundColor(.primaryText)
                    }
                    .tint(.primaryBlue)
                    .padding(12)
                    .background(Color.appBackground) // off-state visible, still on-brand
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
        .preferredColorScheme(.light)

        // STEP 4: Present the in-app form
        .sheet(isPresented: $showFeedbackSheet) {
            NavigationStack {
                FeedbackWebView(url: feedbackURL)
                    .navigationTitle("Feedback Form")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") { showFeedbackSheet = false }
                        }
                    }
            }
        }
    }
}
