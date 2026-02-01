import SwiftUI

struct CachedAsyncImage<Placeholder: View>: View {
    let url: URL?
    @ViewBuilder let placeholder: () -> Placeholder

    @State private var image: UIImage?
    @State private var isFailed = false

    var body: some View {
        if url == nil {
            placeholder()
        } else if let image {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else if isFailed {
            placeholder()
        } else {
            placeholder()
                .overlay(ProgressView())
                .task { await loadImage() }
        }
    }

    private func loadImage() async {
        guard let url else { return }
        do {
            image = try await ImageLoader.shared.image(from: url)
        } catch {
            isFailed = true
        }
    }
}
