import Foundation

@Observable
@MainActor
final class ArtistDetailViewModel {
    private let apiClient: WhitneyAPIClientProtocol

    let artist: Artist
    var artworks: [Artwork] = []
    var isLoadingArtworks = false
    var error: Error?

    init(artist: Artist, apiClient: WhitneyAPIClientProtocol) {
        self.artist = artist
        self.apiClient = apiClient
    }

    func loadArtworks() async {
        isLoadingArtworks = true
        error = nil
        defer { isLoadingArtworks = false }

        do {
            artworks = try await apiClient.fetchArtistArtworks(artistID: artist.id)
        } catch {
            self.error = error
        }
    }
}
