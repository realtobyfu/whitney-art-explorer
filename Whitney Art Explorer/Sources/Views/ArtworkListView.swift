import SwiftUI

struct ArtworkListView: View {
    @State private var viewModel: ArtworkListViewModel

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    init(apiClient: WhitneyAPIClientProtocol = WhitneyAPIClient()) {
        _viewModel = State(initialValue: ArtworkListViewModel(apiClient: apiClient))
    }

    var body: some View {
        @Bindable var viewModel = viewModel
        NavigationStack {
            Group {
                if viewModel.artworks.isEmpty && viewModel.isLoading {
                    ProgressView("Loading artworks...")
                } else if viewModel.artworks.isEmpty && viewModel.error != nil {
                    ContentUnavailableView(
                        "Unable to Load",
                        systemImage: "exclamationmark.triangle",
                        description: Text("Check your connection and try again.")
                    )
                } else if viewModel.artworks.isEmpty && !viewModel.isLoading {
                    ContentUnavailableView.search(text: viewModel.searchText)
                } else {
                    artworkGrid
                }
            }
            .navigationTitle("Artworks")
            .searchable(text: $viewModel.searchText, prompt: "Search artworks")
            .refreshable {
                await viewModel.loadArtworks()
            }
            .task {
                if viewModel.artworks.isEmpty {
                    await viewModel.loadArtworks()
                }
            }
        }
    }

    private var artworkGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.artworks) { artwork in
                    NavigationLink(value: artwork) {
                        ArtworkCardView(artwork: artwork)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)

            if viewModel.hasNextPage {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .task {
                        await viewModel.loadNextPage()
                    }
            }
        }
        .navigationDestination(for: Artwork.self) { artwork in
            ArtworkDetailView(artwork: artwork)
        }
    }
}
