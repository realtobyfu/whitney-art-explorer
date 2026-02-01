import SwiftUI

struct ArtworkDetailView: View {
    let artwork: Artwork

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                artworkImage
                infoSection
            }
        }
        .navigationTitle(artwork.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var artworkImage: some View {
        if artwork.imageURL != nil {
            CachedAsyncImage(url: artwork.imageURL) {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 250)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
        } else {
            HStack(spacing: 4) {
                Image(systemName: "photo")
                    .font(.caption)
                Text("No image available")
                    .font(.caption)
            }
            .foregroundStyle(.tertiary)
            .padding(.horizontal)
        }
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(artwork.title)
                .font(.system(size: 22, weight: .bold))

            if let date = artwork.displayDate {
                Text(date)
                    .font(.system(size: 17))
                    .foregroundStyle(.secondary)
            }

            if let artist = artwork.displayArtistText {
                Text(artist)
                    .font(.system(size: 17))
            }

            if let medium = artwork.medium {
                Text(medium)
                    .font(.body)
                    .padding(.top, 4)
            }

            if let dimensions = artwork.dimensions {
                Text(dimensions)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            if let creditLine = artwork.creditLine {
                Text(creditLine)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .italic()
                    .padding(.top, 4)
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
}
