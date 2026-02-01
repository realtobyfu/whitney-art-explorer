import Foundation

protocol WhitneyAPIClientProtocol {
    func fetchArtists(page: Int, search: String?) async throws -> (artists: [Artist], hasNextPage: Bool)
    func fetchArtistArtworks(artistID: Int) async throws -> [Artwork]
    func fetchExhibitions(page: Int) async throws -> (exhibitions: [Exhibition], hasNextPage: Bool)
    func fetchArtworks(page: Int) async throws -> (artworks: [Artwork], hasNextPage: Bool)
}


final class WhitneyAPIClient: WhitneyAPIClientProtocol {
    private let baseURL = "https://whitney.org/api"
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared) {
        self.session = session
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder = decoder
    }

    func fetchArtists(page: Int, search: String?) async throws -> (artists: [Artist], hasNextPage: Bool) {
        var components = URLComponents(string: "\(baseURL)/artists")!
        var queryItems = [URLQueryItem(name: "page", value: "\(page)")]
        if let search, !search.isEmpty {
            queryItems.append(URLQueryItem(name: "q[name_cont]", value: search))
        }
        components.queryItems = queryItems

        let (data, _) = try await session.data(from: components.url!)
        let response = try decoder.decode(APIResponse<Artist>.self, from: data)
        let artists = response.data.map(\.attributes)
        let hasNextPage = response.links?.next != nil
        return (artists, hasNextPage)
    }

    func fetchArtistArtworks(artistID: Int) async throws -> [Artwork] {
        let url = URL(string: "\(baseURL)/artists/\(artistID)/artworks")!
        let (data, _) = try await session.data(from: url)
        do {
            let response = try decoder.decode(APIResponse<Artwork>.self, from: data)
            return response.data.map(\.attributes)
        } catch {
            print("Decode error for artist \(artistID): \(error)")
            throw error
        }
    }

    func fetchExhibitions(page: Int) async throws -> (exhibitions: [Exhibition], hasNextPage: Bool) {
        var components = URLComponents(string: "\(baseURL)/exhibitions")!
        components.queryItems = [URLQueryItem(name: "page", value: "\(page)")]

        let (data, _) = try await session.data(from: components.url!)
        let response = try decoder.decode(APIResponse<Exhibition>.self, from: data)
        let exhibitions = response.data.map(\.attributes)
        let hasNextPage = response.links?.next != nil
        return (exhibitions, hasNextPage)
    }

    func fetchArtworks(page: Int) async throws -> (artworks: [Artwork], hasNextPage: Bool) {
        var components = URLComponents(string: "\(baseURL)/artworks")!
        components.queryItems = [URLQueryItem(name: "page", value: "\(page)")]

        let (data, _) = try await session.data(from: components.url!)
        let response = try decoder.decode(APIResponse<Artwork>.self, from: data)
        let artworks = response.data.map(\.attributes)
        let hasNextPage = response.links?.next != nil
        return (artworks, hasNextPage)
    }
}
