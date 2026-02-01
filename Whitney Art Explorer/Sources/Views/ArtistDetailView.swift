import SwiftUI

struct ArtistDetailView: View {
    @State private var viewModel: ArtistDetailViewModel

    init(artist: Artist, apiClient: WhitneyAPIClientProtocol = WhitneyAPIClient()) {
        _viewModel = State(initialValue: ArtistDetailViewModel(artist: artist, apiClient: apiClient))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                headerSection
                Divider()
                artworksSection
            }
            .padding()
        }
        .navigationTitle(viewModel.artist.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadArtworks()
        }
    }

    private var headerSection: some View {
        ArtistHeaderSection(artist: viewModel.artist)
    }

    private struct ArtistHeaderSection: View {
        let artist: Artist
        @State private var isBioExpanded = false

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(artist.displayName)
                    .font(.system(size: 28, weight: .bold))
                if !artist.lifeDates.isEmpty {
                    Text(artist.lifeDates)
                        .font(.system(size: 17))
                        .foregroundStyle(.secondary)
                }
                if let biography = artist.biography, !biography.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(biography.strippingHTML())
                            .lineLimit(isBioExpanded ? nil : 4)
                            .animation(.easeInOut, value: isBioExpanded)
                        Button {
                            withAnimation(.easeInOut) {
                                isBioExpanded.toggle()
                            }
                        } label: {
                            Text(isBioExpanded ? "Show less" : "Read more")
                                .font(.subheadline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 4)
                }
            }
        }
    }

    private var artworksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Artworks")
                .font(.system(size: 20, weight: .bold))

            if let error = viewModel.error {
                Text("Error: \(error.localizedDescription)")
                    .foregroundStyle(.red)
                    .font(.caption)
            }

            if viewModel.isLoadingArtworks {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 100)
            } else if viewModel.artworks.isEmpty {
                Text("No artworks found.")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 100)
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(viewModel.artworks) { artwork in
                        NavigationLink {
                            ArtworkDetailView(artwork: artwork)
                        } label: {
                            ArtworkCardView(artwork: artwork)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

extension String {
    func strippingHTML() -> String {
        guard let data = self.data(using: .utf8),
              let attributed = try? NSAttributedString(
                  data: data,
                  options: [
                      .documentType: NSAttributedString.DocumentType.html,
                      .characterEncoding: String.Encoding.utf8.rawValue
                  ],
                  documentAttributes: nil
              ) else {
            return self
        }
        return attributed.string
    }

    func htmlToAttributedString() -> AttributedString {
        let html = """
        <html><head><style>
        body { font-family: -apple-system, Helvetica Neue, sans-serif; font-size: 17px; }
        </style></head><body>\(self)</body></html>
        """
        guard let data = html.data(using: .utf8),
              let nsAttrStr = try? NSAttributedString(
                data: data,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil
              ) else {
            return AttributedString(self)
        }
        return (try? AttributedString(nsAttrStr)) ?? AttributedString(self)
    }
}
