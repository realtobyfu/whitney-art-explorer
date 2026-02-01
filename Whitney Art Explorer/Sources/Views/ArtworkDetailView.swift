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

    private var artworkImage: some View {
        CachedAsyncImage(url: artwork.imageURL) {
            imagePlaceholder
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 250)
        .padding(.horizontal)
    }

    private var imagePlaceholder: some View {
        Rectangle()
            .fill(Color(.systemGray5))
            .frame(height: 300)
            .overlay {
                Image(systemName: "photo")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
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
