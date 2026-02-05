import SwiftUI
import Combine

// MARK: - Models (welcome.json)

struct WelcomeStatement: Codable {
    let id: String
    let title: String
    let location: String
    let body: [String]
    let sign_off: SignOff
}

struct SignOff: Codable {
    let names: [String]
    let role: String
}

// MARK: - Store

final class WelcomeStore: ObservableObject {
    @Published var welcome: WelcomeStatement?
    @Published var loadError: String?

    func loadFromBundle() {
        guard let url = Bundle.main.url(forResource: "welcome", withExtension: "json") else {
            DispatchQueue.main.async {
                self.loadError = """
                welcome.json not found.

                Check:
                • File name is exactly welcome.json
                • Added to Target Membership
                • Listed in Build Phases → Copy Bundle Resources
                """
            }
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let data = try Data(contentsOf: url)
                let decoded = try JSONDecoder().decode(WelcomeStatement.self, from: data)
                DispatchQueue.main.async {
                    self.welcome = decoded
                    self.loadError = nil
                }
            } catch {
                DispatchQueue.main.async {
                    self.loadError = "Failed to load welcome.json: \(error.localizedDescription)"
                }
            }
        }
    }
}

// MARK: - Welcome View (full page)

struct WelcomeView: View {
    @StateObject private var store = WelcomeStore()

    // You said the organisers are Emma + Laura and these are already in Assets
    private let organiserPhotoAssets = [
        "emma_davies",
        "laura_hissey"
    ]

    var body: some View {
        Group {
            if let err = store.loadError {
                PlaceholderPage(title: "Welcome", message: err)

            } else if let w = store.welcome {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {

                        // Organiser photos row
                        HStack(spacing: 16) {
                            ForEach(organiserPhotoAssets, id: \.self) { asset in
                                if UIImage(named: asset) != nil {
                                    Image(asset)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 96, height: 96)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle().stroke(Color.dividerGrey, lineWidth: 1)
                                        )
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 4)

                        // Title
                        Text(w.title)
                            .font(.largeTitle.bold())
                            .foregroundColor(.primaryBlue)

                        Text(w.location)
                            .font(.headline)
                            .foregroundColor(.secondaryText)

                        Divider().overlay(Color.dividerGrey)

                        // Body paragraphs
                        ForEach(w.body, id: \.self) { para in
                            Text(para)
                                .font(.body)
                                .foregroundColor(.primaryText)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        // Sign-off
                        VStack(alignment: .leading, spacing: 4) {
                            Text(w.sign_off.names.joined(separator: " and "))
                                .font(.headline)
                                .foregroundColor(.primaryText)

                            Text(w.sign_off.role)
                                .font(.subheadline)
                                .foregroundColor(.secondaryText)
                        }
                        .padding(.top, 6)

                        Spacer(minLength: 24)
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

            } else {
                PlaceholderPage(title: "Welcome", message: "Loading…")
            }
        }
        .navigationTitle("Welcome")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { NavBrandLogo() }
        .onAppear { store.loadFromBundle() }
    }
}
