import Foundation

@Observable
@MainActor
final class ExhibitionListViewModel {
    private let apiClient: WhitneyAPIClientProtocol

    var exhibitions: [Exhibition] = []
    var isLoading = false
    var error: Error?
    var hasNextPage = false
    private var currentPage = 1
    private var loadedPages: Set<Int> = []

    init(apiClient: WhitneyAPIClientProtocol) {
        self.apiClient = apiClient
    }

    func loadExhibitions() async {
        currentPage = 1
        loadedPages = [1]
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            let result = try await apiClient.fetchExhibitions(page: 1)
            exhibitions = result.exhibitions
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
            let result = try await apiClient.fetchExhibitions(page: currentPage)
            exhibitions.append(contentsOf: result.exhibitions)
            hasNextPage = result.hasNextPage
        } catch {
            self.error = error
            loadedPages.remove(nextPage)
            currentPage -= 1
        }
    }
}
