import SwiftUI
import PDFKit
import UniformTypeIdentifiers

struct CertificateView: View {

    // MARK: - Gate certificate behind feedback completion
    @AppStorage("feedbackComplete") private var feedbackComplete: Bool = false

    @State private var attendeeName: String = ""
    @State private var attendeeOrg: String = ""

    // IMPORTANT: store ONLY a file URL (not PDF Data) to keep memory low
    @State private var pdfURL: URL? = nil

    @State private var showFullPreview: Bool = false
    @State private var isGenerating: Bool = false
    @State private var generationError: String? = nil

    private let conferenceTitle = "Footsteps to Change Conference 2026"
    private let venueLine = "Warwick Arts Centre, University of Warwick, Coventry CV4 7AL"

    // Asset names MUST match exactly
    private let logoAssetName = "conferenceLogo"
    private let emmaSignatureAssetName = "emma_signature"
    private let lauraSignatureAssetName: String? = "laura_signature" // ✅ NOW ENABLED

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                Text("Certificate")
                    .font(.largeTitle.bold())
                    .foregroundColor(.primaryBlue)

                Text("Generate your Certificate of Attendance once feedback has been completed.")
                    .foregroundColor(.secondaryText)

                if !feedbackComplete {
                    lockedView
                } else {
                    unlockedView
                }

                Spacer(minLength: 24)
            }
            .padding()
        }
        .background(Color.appBackground)
        .navigationTitle("Certificate")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { NavBrandLogo() }
    }

    // MARK: - Locked state

    private var lockedView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Locked")
                .font(.headline)
                .foregroundColor(.primaryText)

            Text("Please complete the feedback form first. Once completed, your certificate will unlock here.")
                .foregroundColor(.secondaryText)

            NavigationLink {
                FeedbackView()
            } label: {
                Text("Go to Feedback →")
                    .font(.headline)
                    .foregroundColor(.primaryBlue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.cardBackground)
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.dividerGrey, lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(Color.cardBackground)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.dividerGrey, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
    }

    // MARK: - Unlocked state

    private var unlockedView: some View {
        VStack(alignment: .leading, spacing: 14) {

            VStack(alignment: .leading, spacing: 10) {
                Text("Your details")
                    .font(.headline)
                    .foregroundColor(.primaryText)

                TextField("Full name", text: $attendeeName)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .padding(12)
                    .background(Color.cardBackground)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.dividerGrey, lineWidth: 1)
                    )
                    .foregroundColor(.primaryText)

                TextField("Organisation / Location (optional)", text: $attendeeOrg)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .padding(12)
                    .background(Color.cardBackground)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.dividerGrey, lineWidth: 1)
                    )
                    .foregroundColor(.primaryText)
            }

            if let generationError {
                Text(generationError)
                    .font(.subheadline)
                    .foregroundColor(.red)
            }

            Button {
                generateCertificateSafely()
            } label: {
                HStack(spacing: 10) {
                    if isGenerating { ProgressView().tint(.white) }
                    Text(pdfURL == nil ? "Generate certificate" : "Refresh certificate")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.primaryBlue)
                .cornerRadius(14)
            }
            .buttonStyle(.plain)
            .disabled(isGenerating || attendeeName.trimmed.isEmpty)

            if let pdfURL {
                VStack(alignment: .leading, spacing: 10) {

                    HStack {
                        Text("Preview")
                            .font(.headline)
                            .foregroundColor(.primaryText)

                        Spacer()

                        Button {
                            showFullPreview = true
                        } label: {
                            Text("Full screen")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.primaryBlue)
                        }
                        .buttonStyle(.plain)
                    }

                    PDFKitPreviewURL(url: pdfURL)
                        .frame(height: 420)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.dividerGrey, lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)

                    ShareLink(item: pdfURL) {
                        Label("Share / Save certificate", systemImage: "square.and.arrow.up")
                            .font(.headline)
                            .foregroundColor(.primaryBlue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.cardBackground)
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.dividerGrey, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 6)
                .sheet(isPresented: $showFullPreview) {
                    NavigationStack {
                        PDFKitPreviewURL(url: pdfURL)
                            .ignoresSafeArea()
                            .navigationTitle("Certificate Preview")
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .topBarTrailing) {
                                    Button("Done") { showFullPreview = false }
                                }
                            }
                    }
                }
            }
        }
        .padding(14)
        .background(Color.cardBackground)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.dividerGrey, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
    }

    // MARK: - Generation (memory-safe)

    private func generateCertificateSafely() {
        generationError = nil

        let name = attendeeName.trimmed
        guard !name.isEmpty else { return }

        isGenerating = true

        // Drop old preview first (important)
        let oldURL = pdfURL
        pdfURL = nil

        DispatchQueue.global(qos: .userInitiated).async {
            autoreleasepool {

                let data = CertificatePDFRenderer.makePDF(
                    attendeeName: name,
                    attendeeOrg: attendeeOrg.trimmed,
                    conferenceTitle: conferenceTitle,
                    venueLine: venueLine,
                    logoAssetName: logoAssetName,
                    emmaSignatureAssetName: emmaSignatureAssetName,
                    lauraSignatureAssetName: lauraSignatureAssetName // ✅ now passed through
                )

                if data.isEmpty {
                    DispatchQueue.main.async {
                        self.isGenerating = false
                        self.generationError = "Certificate generation failed (empty PDF). Check asset names."
                    }
                    return
                }

                let url = writePDFToTemporaryFile(
                    data: data,
                    fileName: "Certificate - \(safeFileComponent(name)).pdf"
                )

                DispatchQueue.main.async {
                    if let oldURL { try? FileManager.default.removeItem(at: oldURL) }

                    self.pdfURL = url
                    self.isGenerating = false

                    if url == nil {
                        self.generationError = "PDF created, but could not prepare a share/preview file."
                    }
                }
            }
        }
    }

    private func writePDFToTemporaryFile(data: Data, fileName: String) -> URL? {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        do {
            try data.write(to: url, options: .atomic)
            return url
        } catch {
            print("Failed to write PDF: \(error)")
            return nil
        }
    }

    private func safeFileComponent(_ s: String) -> String {
        let bad = CharacterSet(charactersIn: "/\\?%*|\"<>:")
        return s.components(separatedBy: bad).joined(separator: "-")
    }
}

// MARK: - PDF Preview from URL (lower memory than Data)

struct PDFKitPreviewURL: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> PDFView {
        let v = PDFView()
        v.autoScales = true
        v.displayMode = .singlePage
        v.displayDirection = .vertical
        v.usePageViewController(false)
        v.backgroundColor = .clear
        return v
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        uiView.document = nil
        uiView.document = PDFDocument(url: url)
    }
}

// MARK: - PDF Renderer (thumbnails images before drawing)

enum CertificatePDFRenderer {

    static func makePDF(
        attendeeName: String,
        attendeeOrg: String,
        conferenceTitle: String,
        venueLine: String,
        logoAssetName: String,
        emmaSignatureAssetName: String,
        lauraSignatureAssetName: String?
    ) -> Data {

        let pageSize = CGSize(width: 842, height: 595)

        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize))
        return renderer.pdfData { ctx in
            ctx.beginPage()

            let cg = ctx.cgContext

            // Background
            UIColor(Color.appBackground).setFill()
            cg.fill(CGRect(origin: .zero, size: pageSize))

            // Card
            let cardRect = CGRect(x: 40, y: 40, width: pageSize.width - 80, height: pageSize.height - 80)
            let card = UIBezierPath(roundedRect: cardRect, cornerRadius: 18)
            UIColor.white.setFill()
            card.fill()

            UIColor(Color.dividerGrey).setStroke()
            card.lineWidth = 2
            card.stroke()

            var cursorY = cardRect.minY + 28

            // Logo
            if let logo = loadThumbnail(assetName: logoAssetName, targetSize: CGSize(width: 140, height: 140)) {
                let rect = CGRect(x: pageSize.width/2 - 35, y: cursorY, width: 70, height: 70)
                logo.draw(in: rect)
            }
            cursorY += 90

            // Title
            cursorY = drawCenteredText(
                "Certificate of Attendance",
                font: .systemFont(ofSize: 30, weight: .bold),
                color: UIColor(Color.primaryText),
                y: cursorY,
                pageWidth: pageSize.width
            )

            cursorY = drawCenteredText(
                conferenceTitle,
                font: .systemFont(ofSize: 22, weight: .semibold),
                color: UIColor(Color.primaryBlue),
                y: cursorY + 6,
                pageWidth: pageSize.width
            )

            cursorY += 28

            // Body
            cursorY = drawCenteredText(
                "This certifies that",
                font: .systemFont(ofSize: 17),
                color: UIColor(Color.secondaryText),
                y: cursorY,
                pageWidth: pageSize.width
            )

            cursorY = drawCenteredText(
                attendeeName,
                font: .systemFont(ofSize: 30, weight: .bold),
                color: UIColor(Color.primaryText),
                y: cursorY + 2,
                pageWidth: pageSize.width
            )

            if !attendeeOrg.isEmpty {
                cursorY = drawCenteredText(
                    attendeeOrg,
                    font: .systemFont(ofSize: 16, weight: .medium),
                    color: UIColor(Color.secondaryText),
                    y: cursorY + 2,
                    pageWidth: pageSize.width
                )
            }

            cursorY = drawCenteredText(
                "has attended the conference.",
                font: .systemFont(ofSize: 17),
                color: UIColor(Color.secondaryText),
                y: cursorY + 4,
                pageWidth: pageSize.width
            )

            // Venue pinned above signatures
            let venueY = max(cursorY + 18, cardRect.maxY - 165)
            _ = drawCenteredText(
                venueLine,
                font: .systemFont(ofSize: 14),
                color: UIColor(Color.secondaryText),
                y: venueY,
                pageWidth: pageSize.width
            )

            // Signatures pinned near bottom
            let sigY = cardRect.maxY - 150

            drawSignature(
                name: "Emma Davies",
                role: "Conference Organiser",
                asset: emmaSignatureAssetName,
                xCenter: cardRect.midX - 180,
                y: sigY
            )

            drawSignature(
                name: "Laura Hissey",
                role: "Conference Organiser",
                asset: lauraSignatureAssetName, // ✅ will draw if asset exists
                xCenter: cardRect.midX + 180,
                y: sigY
            )
        }
    }

    private static func loadThumbnail(assetName: String, targetSize: CGSize) -> UIImage? {
        guard let img = UIImage(named: assetName) else { return nil }
        return img.preparingThumbnail(of: targetSize) ?? img
    }

    private static func drawCenteredText(
        _ text: String,
        font: UIFont,
        color: UIColor,
        y: CGFloat,
        pageWidth: CGFloat
    ) -> CGFloat {

        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center

        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paragraph
        ]

        let rect = CGRect(x: 80, y: y, width: pageWidth - 160, height: 400)

        let bounding = NSString(string: text).boundingRect(
            with: CGSize(width: rect.width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin],
            attributes: attrs,
            context: nil
        )

        NSString(string: text).draw(
            in: CGRect(x: rect.minX, y: y, width: rect.width, height: bounding.height),
            withAttributes: attrs
        )

        return y + bounding.height
    }

    private static func drawSignature(
        name: String,
        role: String,
        asset: String?,
        xCenter: CGFloat,
        y: CGFloat
    ) {

        let blockWidth: CGFloat = 220
        let sigHeight: CGFloat = 55

        if let asset,
           let image = loadThumbnail(assetName: asset, targetSize: CGSize(width: 440, height: 110)) {

            image.draw(in: CGRect(x: xCenter - blockWidth/2, y: y, width: blockWidth, height: sigHeight))
        } else {
            UIColor(Color.dividerGrey).setFill()
            UIRectFill(CGRect(x: xCenter - blockWidth/2, y: y + sigHeight - 2, width: blockWidth, height: 2))
        }

        let para = NSMutableParagraphStyle()
        para.alignment = .center

        let nameAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
            .foregroundColor: UIColor(Color.primaryText),
            .paragraphStyle: para
        ]

        let roleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor(Color.secondaryText),
            .paragraphStyle: para
        ]

        NSString(string: name).draw(
            in: CGRect(x: xCenter - blockWidth/2, y: y + sigHeight + 8, width: blockWidth, height: 18),
            withAttributes: nameAttrs
        )

        NSString(string: role).draw(
            in: CGRect(x: xCenter - blockWidth/2, y: y + sigHeight + 26, width: blockWidth, height: 16),
            withAttributes: roleAttrs
        )
    }
}

// MARK: - Helpers

private extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}
