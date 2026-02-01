import SwiftUI

struct ArtworkCardView: View {
    let artwork: Artwork

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if artwork.imageURL != nil {
                CachedAsyncImage(url: artwork.imageURL) {
                    placeholder
                }
                .frame(maxWidth: .infinity, minHeight: 120)
                .clipped()
                .cornerRadius(8)
                .padding(.bottom, 2)
            } else {
                HStack(spacing: 4) {
                    Image(systemName: "photo")
                        .font(.caption2)
                    Text("No image")
                        .font(.caption2)
                }
                .foregroundStyle(.tertiary)
                .padding(.bottom, 2)
            }

            Text(artwork.title)
                .font(.system(size: 14, weight: .bold))
                .lineLimit(2)
                .foregroundStyle(.primary)

            if let date = artwork.displayDate {
                Text(date)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var placeholder: some View {
        Rectangle()
            .fill(Color(.systemGray5))
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                Image(systemName: "photo")
                    .foregroundStyle(.secondary)
            }
    }
}
