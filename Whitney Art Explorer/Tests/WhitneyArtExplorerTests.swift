import Testing
@testable import Whitney_Art_Explorer

// MARK: - Mock API Client

struct MockWhitneyAPIClient: WhitneyAPIClientProtocol {
    var artists: [Artist] = []
    var artworks: [Artwork] = []
    var exhibitions: [Exhibition] = []
    var hasNextPage: Bool = false
    var hasNextExhibitionPage: Bool = false
    var hasNextArtworkPage: Bool = false
    var shouldThrow: Bool = false

    func fetchArtists(page: Int, search: String?) async throws -> (artists: [Artist], hasNextPage: Bool) {
        if shouldThrow { throw MockError.networkError }
        return (artists, hasNextPage)
    }

    func fetchArtistArtworks(artistID: Int) async throws -> [Artwork] {
        if shouldThrow { throw MockError.networkError }
        return artworks
    }

    func fetchExhibitions(page: Int) async throws -> (exhibitions: [Exhibition], hasNextPage: Bool) {
        if shouldThrow { throw MockError.networkError }
        return (exhibitions, hasNextExhibitionPage)
    }

    func fetchArtworks(page: Int) async throws -> (artworks: [Artwork], hasNextPage: Bool) {
        if shouldThrow { throw MockError.networkError }
        return (artworks, hasNextArtworkPage)
    }
}

enum MockError: Error {
    case networkError
}

// MARK: - Sample Data

extension Artist {
    static let sample = Artist(
        id: 1,
        displayName: "Test Artist",
        sortName: "Artist Test",
        displayDate: "1940–2017",
        beginDate: "1940",
        endDate: "2017",
        biography: "A test artist.",
        onView: true
    )

    static let livingArtist = Artist(
        id: 2,
        displayName: "Living Artist",
        sortName: "Artist Living",
        displayDate: "1980–",
        beginDate: "1980",
        endDate: "0",
        biography: nil,
        onView: false
    )
}

extension Artwork {
    static let sample = Artwork(
        id: 100,
        title: "Test Artwork",
        displayDate: "2020",
        medium: "Oil on canvas",
        dimensions: "24 × 36 in.",
        creditLine: "Gift of the artist",
        displayArtistText: "Test Artist",
        images: [ArtworkImage(id: 1, url: "https://example.com/image.jpg")],
        aiAltText: "A test image"
    )
}

// MARK: - Artist Model Tests

@Test func artistLifeDates_withBeginAndEnd() {
    let artist = Artist.sample
    #expect(artist.lifeDates == "1940–2017")
}

@Test func artistLifeDates_livingArtist() {
    let artist = Artist.livingArtist
    #expect(artist.lifeDates == "1980–present")
}

@Test func artistLifeDates_noBeginDate() {
    let artist = Artist(
        id: 3, displayName: "Unknown", sortName: "Unknown",
        displayDate: nil, beginDate: nil, endDate: nil,
        biography: nil, onView: false
    )
    #expect(artist.lifeDates == "")
}

// MARK: - ArtistListViewModel Tests

@Test @MainActor func loadArtists_setsArtistsOnSuccess() async {
    let mock = MockWhitneyAPIClient(artists: [.sample], hasNextPage: false)
    let vm = ArtistListViewModel(apiClient: mock)

    await vm.loadArtists()

    #expect(vm.artists.count == 1)
    #expect(vm.artists.first?.displayName == "Test Artist")
    #expect(vm.isLoading == false)
    #expect(vm.error == nil)
}

@Test @MainActor func loadArtists_setsErrorOnFailure() async {
    let mock = MockWhitneyAPIClient(shouldThrow: true)
    let vm = ArtistListViewModel(apiClient: mock)

    await vm.loadArtists()

    #expect(vm.artists.isEmpty)
    #expect(vm.error != nil)
    #expect(vm.isLoading == false)
}

@Test @MainActor func loadArtists_setsHasNextPage() async {
    let mock = MockWhitneyAPIClient(artists: [.sample], hasNextPage: true)
    let vm = ArtistListViewModel(apiClient: mock)

    await vm.loadArtists()

    #expect(vm.hasNextPage == true)
}

@Test @MainActor func loadNextPage_appendsArtists() async {
    let mock = MockWhitneyAPIClient(artists: [.sample], hasNextPage: true)
    let vm = ArtistListViewModel(apiClient: mock)

    await vm.loadArtists()
    #expect(vm.artists.count == 1)

    await vm.loadNextPage()
    #expect(vm.artists.count == 2)
}

// MARK: - ArtistDetailViewModel Tests

@Test @MainActor func loadArtworks_setsArtworksOnSuccess() async {
    let mock = MockWhitneyAPIClient(artworks: [.sample])
    let vm = ArtistDetailViewModel(artist: .sample, apiClient: mock)

    await vm.loadArtworks()

    #expect(vm.artworks.count == 1)
    #expect(vm.artworks.first?.title == "Test Artwork")
    #expect(vm.isLoadingArtworks == false)
    #expect(vm.error == nil)
}

@Test @MainActor func loadArtworks_setsErrorOnFailure() async {
    let mock = MockWhitneyAPIClient(shouldThrow: true)
    let vm = ArtistDetailViewModel(artist: .sample, apiClient: mock)

    await vm.loadArtworks()

    #expect(vm.artworks.isEmpty)
    #expect(vm.error != nil)
    #expect(vm.isLoadingArtworks == false)
}

// MARK: - Artwork Model Tests

@Test func artworkImageURL_returnsFirstImageURL() {
    let artwork = Artwork.sample
    #expect(artwork.imageURL?.absoluteString == "https://example.com/image.jpg")
}

@Test func artworkImageURL_returnsNilWhenNoImages() {
    let artwork = Artwork(
        id: 200, title: "No Image", displayDate: nil, medium: nil,
        dimensions: nil, creditLine: nil, displayArtistText: nil,
        images: [], aiAltText: nil
    )
    #expect(artwork.imageURL == nil)
}

// MARK: - Exhibition Sample Data

extension Exhibition {
    static let sample = Exhibition(
        id: 10,
        title: "Test Exhibition",
        startTime: "2024-01-15T00:00:00.000Z",
        endTime: "2024-06-30T00:00:00.000Z",
        dateOverride: nil,
        url: "/exhibitions/test",
        primaryText: "<p>A test exhibition description.</p>"
    )

    static let overrideDateExhibition = Exhibition(
        id: 11,
        title: "Override Date Exhibition",
        startTime: nil,
        endTime: nil,
        dateOverride: "Ongoing",
        url: nil,
        primaryText: nil
    )
}

// MARK: - Exhibition Model Tests

@Test func exhibitionDateRange_usesOverrideWhenPresent() {
    let exhibition = Exhibition.overrideDateExhibition
    #expect(exhibition.dateRange == "Ongoing")
}

@Test func exhibitionDateRange_formatsStartAndEnd() {
    let exhibition = Exhibition.sample
    #expect(!exhibition.dateRange.isEmpty)
    #expect(exhibition.dateRange.contains("–"))
}

@Test func exhibitionDateRange_emptyWhenNoData() {
    let exhibition = Exhibition(
        id: 12, title: "Empty", startTime: nil, endTime: nil,
        dateOverride: nil, url: nil, primaryText: nil
    )
    #expect(exhibition.dateRange == "")
}

// MARK: - ExhibitionListViewModel Tests

@Test @MainActor func loadExhibitions_setsExhibitionsOnSuccess() async {
    let mock = MockWhitneyAPIClient(exhibitions: [.sample], hasNextExhibitionPage: false)
    let vm = ExhibitionListViewModel(apiClient: mock)

    await vm.loadExhibitions()

    #expect(vm.exhibitions.count == 1)
    #expect(vm.exhibitions.first?.title == "Test Exhibition")
    #expect(vm.isLoading == false)
    #expect(vm.error == nil)
}

@Test @MainActor func loadExhibitions_setsErrorOnFailure() async {
    let mock = MockWhitneyAPIClient(shouldThrow: true)
    let vm = ExhibitionListViewModel(apiClient: mock)

    await vm.loadExhibitions()

    #expect(vm.exhibitions.isEmpty)
    #expect(vm.error != nil)
    #expect(vm.isLoading == false)
}

@Test @MainActor func loadExhibitions_setsHasNextPage() async {
    let mock = MockWhitneyAPIClient(exhibitions: [.sample], hasNextExhibitionPage: true)
    let vm = ExhibitionListViewModel(apiClient: mock)

    await vm.loadExhibitions()

    #expect(vm.hasNextPage == true)
}

@Test @MainActor func loadExhibitionsNextPage_appendsExhibitions() async {
    let mock = MockWhitneyAPIClient(exhibitions: [.sample], hasNextExhibitionPage: true)
    let vm = ExhibitionListViewModel(apiClient: mock)

    await vm.loadExhibitions()
    #expect(vm.exhibitions.count == 1)

    await vm.loadNextPage()
    #expect(vm.exhibitions.count == 2)
}

// MARK: - ArtworkListViewModel Tests

@Test @MainActor func artworkListVM_setsArtworksOnSuccess() async {
    let mock = MockWhitneyAPIClient(artworks: [.sample], hasNextArtworkPage: false)
    let vm = ArtworkListViewModel(apiClient: mock)

    await vm.loadArtworks()

    #expect(vm.artworks.count == 1)
    #expect(vm.artworks.first?.title == "Test Artwork")
    #expect(vm.isLoading == false)
    #expect(vm.error == nil)
}

@Test @MainActor func artworkListVM_setsErrorOnFailure() async {
    let mock = MockWhitneyAPIClient(shouldThrow: true)
    let vm = ArtworkListViewModel(apiClient: mock)

    await vm.loadArtworks()

    #expect(vm.artworks.isEmpty)
    #expect(vm.error != nil)
    #expect(vm.isLoading == false)
}

@Test @MainActor func artworkListVM_setsHasNextPage() async {
    let mock = MockWhitneyAPIClient(artworks: [.sample], hasNextArtworkPage: true)
    let vm = ArtworkListViewModel(apiClient: mock)

    await vm.loadArtworks()

    #expect(vm.hasNextPage == true)
}

@Test @MainActor func artworkListVM_appendsArtworksOnNextPage() async {
    let mock = MockWhitneyAPIClient(artworks: [.sample], hasNextArtworkPage: true)
    let vm = ArtworkListViewModel(apiClient: mock)

    await vm.loadArtworks()
    #expect(vm.artworks.count == 1)

    await vm.loadNextPage()
    #expect(vm.artworks.count == 2)
}
