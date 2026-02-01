import SwiftUI

struct ArtworkCardView: View {
    let artwork: Artwork

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            CachedAsyncImage(url: artwork.imageURL) {
                placeholder
            }
            .frame(maxWidth: .infinity, minHeight: 120)
            .clipped()
            .cornerRadius(8)
            .padding(.bottom, 2)

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
