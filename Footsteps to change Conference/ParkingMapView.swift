import SwiftUI

struct ParkingMapView: View {
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ZoomableScrollView {
                Image("warwick_parking_map")
                    .resizable()
                    .scaledToFit()
                    .padding(12)
            }
        }
        .navigationTitle("Parking Map")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { NavBrandLogo() }
    }
}

// MARK: - Zoomable scroll view (pinch to zoom)

struct ZoomableScrollView<Content: View>: UIViewRepresentable {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(rootView: content)
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator

        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        scrollView.zoomScale = 1.0

        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bouncesZoom = true
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.backgroundColor = .clear

        // Container view: THIS is what we zoom
        let containerView = context.coordinator.containerView
        containerView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(containerView)

        // Host SwiftUI content inside container
        let hostedView = context.coordinator.hostingController.view!
        hostedView.translatesAutoresizingMaskIntoConstraints = false
        hostedView.backgroundColor = .clear
        containerView.addSubview(hostedView)

        // Pin hosted view to container
        NSLayoutConstraint.activate([
            hostedView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            hostedView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            hostedView.topAnchor.constraint(equalTo: containerView.topAnchor),
            hostedView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        // Pin container to scroll view content layout
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),

            // Start with container sized to the viewport (so the image fits nicely at zoomScale 1)
            containerView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            containerView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        ])

        return scrollView
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {
        context.coordinator.hostingController.rootView = content
    }

    final class Coordinator: NSObject, UIScrollViewDelegate {
        let hostingController: UIHostingController<Content>
        let containerView = UIView()

        init(rootView: Content) {
            self.hostingController = UIHostingController(rootView: rootView)
            super.init()
        }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            // Zoom the container (not the scroll view’s first subview)
            containerView
        }

        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            // Optional: keep content centered when zoomed out/in
            let boundsSize = scrollView.bounds.size
            let contentFrame = containerView.frame

            let offsetX = max((boundsSize.width - contentFrame.width) * 0.5, 0)
            let offsetY = max((boundsSize.height - contentFrame.height) * 0.5, 0)

            containerView.center = CGPoint(
                x: contentFrame.width * 0.5 + offsetX,
                y: contentFrame.height * 0.5 + offsetY
            )
        }
    }
}
