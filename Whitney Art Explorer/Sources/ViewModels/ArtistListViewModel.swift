import Foundation

@Observable
final class ArtistListViewModel {
    private let apiClient: WhitneyAPIClientProtocol

    var artists: [Artist] = []
    var isLoading = false
    var error: Error?
    var searchText = ""
    var hasNextPage = false
    private var currentPage = 1
    private var searchTask: Task<Void, Never>?

    init(apiClient: WhitneyAPIClientProtocol) {
        self.apiClient = apiClient
    }

    func loadArtists() async {
        currentPage = 1
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            let result = try await apiClient.fetchArtists(page: 1, search: searchText.isEmpty ? nil : searchText)
            artists = result.artists
            hasNextPage = result.hasNextPage
        } catch {
            self.error = error
        }
    }

    func loadNextPage() async {
        guard hasNextPage, !isLoading else { return }
        currentPage += 1
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await apiClient.fetchArtists(page: currentPage, search: searchText.isEmpty ? nil : searchText)
            artists.append(contentsOf: result.artists)
            hasNextPage = result.hasNextPage
        } catch {
            self.error = error
            currentPage -= 1
        }
    }

    func searchArtists() {
        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            await loadArtists()
        }
    }
}
