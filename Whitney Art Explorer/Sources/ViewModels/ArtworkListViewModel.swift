import Foundation

@Observable
@MainActor
final class ArtworkListViewModel {
    private let apiClient: WhitneyAPIClientProtocol

    private var allArtworks: [Artwork] = []
    var isLoading = false
    var error: Error?
    var searchText = ""
    var hasNextPage = false
    private var currentPage = 1
    private var loadedPages: Set<Int> = []

    var artworks: [Artwork] {
        guard !searchText.isEmpty else { return allArtworks }
        let query = searchText.lowercased()
        return allArtworks.filter { $0.title.lowercased().contains(query) }
    }

    init(apiClient: WhitneyAPIClientProtocol) {
        self.apiClient = apiClient
    }

    func loadArtworks() async {
        currentPage = 1
        loadedPages = [1]
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            let result = try await apiClient.fetchArtworks(page: 1)
            allArtworks = result.artworks
            hasNextPage = result.hasNextPage
        } catch {
            self.error = error
        }
    }

    func loadNextPage() async {
        let nextPage = currentPage + 1
        guard hasNextPage, !isLoading, !loadedPages.contains(nextPage) else { return }
        currentPage = nextPage
        loadedPages.insert(nextPage)
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await apiClient.fetchArtworks(page: currentPage)
            allArtworks.append(contentsOf: result.artworks)
            hasNextPage = result.hasNextPage
        } catch {
            self.error = error
            loadedPages.remove(nextPage)
            currentPage -= 1
        }
    }
}
