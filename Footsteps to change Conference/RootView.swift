import SwiftUI

struct RootView: View {
    @AppStorage("hasEnteredApp") private var hasEnteredApp: Bool = false

    var body: some View {
        if hasEnteredApp {
            HomeHubView()
        } else {
            LandingView()
        }
    }
}
