import SwiftUI
import PDFKit

struct ParkingMapView: View {

    private let parkingURL = URL(string:
        "https://citycentre.apcoa.co.uk/bookingsummary/customerdetail/3992/warwick-university-car-parks/1268/conference-parking"
    )!

    // ✅ Your confirmed asset name
    private let mapAssetName = "warwick_parking_map"

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // MARK: — Map (zoomable)
                ZoomableImageCard(assetName: mapAssetName)
                    .padding(.horizontal)

                // MARK: — Parking info (polished)
                ParkingInfoCard(parkingURL: parkingURL)
                    .padding(.horizontal)

                Spacer(minLength: 30)
            }
            .padding(.top, 12)
        }
        .background(Color.appBackground)
        .navigationTitle("Parking")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { NavBrandLogo() }
    }
}

// MARK: - Zoomable Map Card (with safe fallback)

private struct ZoomableImageCard: View {
    let assetName: String

    var body: some View {
        Group {
            if let uiImage = UIImage(named: assetName) {
                ZoomableImageView(uiImage: uiImage)
                    .frame(height: 420) // a little taller = better map UX
                    .background(Color.appBackground) // looks intentional when zoomed out
            } else {
                VStack(spacing: 10) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.title)
                        .foregroundColor(.accentOrange)

                    Text("Parking map missing")
                        .font(.headline)
                        .foregroundColor(.primaryText)

                    Text("Check asset name: \(assetName)")
                        .font(.subheadline)
                        .foregroundColor(.secondaryText)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 220)
                .background(Color.appBackground)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.dividerGrey, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
    }
}

// MARK: - Pinch-to-zoom image (centred properly)

struct ZoomableImageView: View {
    let uiImage: UIImage

    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1

    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    private var isZoomed: Bool { scale > 1.01 }

    var body: some View {

        GeometryReader { geo in

            let containerSize = geo.size

            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .frame(width: containerSize.width,
                       height: containerSize.height,
                       alignment: .center)

                .scaleEffect(scale)
                .offset(offset)

                // MARK: — Pinch Gesture
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            let newScale = lastScale * value
                            scale = min(max(newScale, 1), 5)

                            offset = clampedOffset(
                                offset,
                                container: containerSize
                            )
                        }
                        .onEnded { _ in
                            lastScale = scale

                            if scale <= 1.01 {
                                withAnimation(.spring()) {
                                    scale = 1
                                    lastScale = 1
                                    offset = .zero
                                    lastOffset = .zero
                                }
                            }
                        }
                )

                // MARK: — Drag Gesture (ONLY when zoomed)
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { value in
                            guard isZoomed else { return }

                            let proposed = CGSize(
                                width: lastOffset.width + value.translation.width,
                                height: lastOffset.height + value.translation.height
                            )

                            offset = clampedOffset(
                                proposed,
                                container: containerSize
                            )
                        }
                        .onEnded { _ in
                            guard isZoomed else { return }
                            lastOffset = offset
                        }
                )

                // MARK: — Double Tap Reset
                .onTapGesture(count: 2) {
                    withAnimation(.spring(response: 0.35,
                                          dampingFraction: 0.8)) {
                        scale = 1
                        lastScale = 1
                        offset = .zero
                        lastOffset = .zero
                    }
                }
        }
        .clipped()
    }

    // MARK: - Edge Clamp Logic

    private func clampedOffset(
        _ proposed: CGSize,
        container: CGSize
    ) -> CGSize {

        // When scaled, the image grows beyond container.
        let maxX = (container.width * (scale - 1)) / 2
        let maxY = (container.height * (scale - 1)) / 2

        let clampedX = min(max(proposed.width, -maxX), maxX)
        let clampedY = min(max(proposed.height, -maxY), maxY)

        return CGSize(width: clampedX, height: clampedY)
    }
}

// MARK: - Parking info card

private struct ParkingInfoCard: View {

    let parkingURL: URL

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            Label("Free Delegate Parking", systemImage: "parkingsign.circle.fill")
                .font(.title3.weight(.semibold))
                .foregroundColor(.primaryBlue)

            Text("""
All conference attendees are entitled to free parking on campus.

Car parks operate using Automatic Number Plate Recognition (ANPR), so your vehicle must be registered either before arrival or on the day.
""")
            .foregroundColor(.secondaryText)

            Divider()

            VStack(alignment: .leading, spacing: 10) {
                Text("How to register")
                    .font(.headline)
                    .foregroundColor(.primaryText)

                RegistrationRow("Enter your personal details and confirm the booking summary.")
                RegistrationRow("Select arrival and departure times — we recommend allowing extra time.")
                RegistrationRow("Use promotional code", highlight: "WOKJL")
                RegistrationRow("Complete your booking to secure free parking.")
            }

            Link(destination: parkingURL) {
                HStack {
                    Text("Register Parking")
                        .font(.headline)

                    Spacer()

                    Image(systemName: "arrow.up.right.circle.fill")
                        .font(.title3)
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.primaryBlue)
                .cornerRadius(16)
                .shadow(color: Color.primaryBlue.opacity(0.35), radius: 8, x: 0, y: 4)
            }

            Text("You may also register on arrival using QR codes displayed in conference areas.")
                .font(.footnote)
                .foregroundColor(.secondaryText)
        }
        .padding(18)
        .background(Color.cardBackground)
        .cornerRadius(22)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.dividerGrey, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
    }
}

// MARK: - Registration row helper

private struct RegistrationRow: View {
    let text: String
    var highlight: String? = nil

    init(_ text: String, highlight: String? = nil) {
        self.text = text
        self.highlight = highlight
    }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.primaryBlue)
                .font(.system(size: 16))

            if let highlight {
                (Text(text + " ")
                    .foregroundColor(.secondaryText)
                 + Text(highlight)
                    .foregroundColor(.primaryBlue)
                    .fontWeight(.semibold)
                )
            } else {
                Text(text)
                    .foregroundColor(.secondaryText)
            }
        }
    }
}
