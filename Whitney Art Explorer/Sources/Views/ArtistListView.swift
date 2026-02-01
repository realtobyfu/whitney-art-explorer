import SwiftUI

struct ArtistListView: View {
    @State private var viewModel: ArtistListViewModel

    init(apiClient: WhitneyAPIClientProtocol = WhitneyAPIClient()) {
        _viewModel = State(initialValue: ArtistListViewModel(apiClient: apiClient))
    }

    var body: some View {
        @Bindable var viewModel = viewModel
        NavigationStack {
            Group {
                if viewModel.artists.isEmpty && viewModel.isLoading {
                    ProgressView("Loading artists...")
                } else if viewModel.artists.isEmpty && viewModel.error != nil {
                    ContentUnavailableView(
                        "Unable to Load",
                        systemImage: "exclamationmark.triangle",
                        description: Text("Check your connection and try again.")
                    )
                } else if viewModel.artists.isEmpty && !viewModel.isLoading {
                    ContentUnavailableView.search(text: viewModel.searchText)
                } else {
                    artistList
                }
            }
            .navigationTitle("Whitney Artists")
            .searchable(text: $viewModel.searchText, prompt: "Search artists")
            .refreshable {
                await viewModel.loadArtists()
            }
            .task {
                if viewModel.artists.isEmpty {
                    await viewModel.loadArtists()
                }
            }
        }
    }

    private var artistList: some View {
        List {
            ForEach(viewModel.artists) { artist in
                NavigationLink(value: artist) {
                    ArtistRowView(artist: artist)
                }
            }
            if viewModel.hasNextPage {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .task {
                        await viewModel.loadNextPage()
                    }
            }
        }
        .navigationDestination(for: Artist.self) { artist in
            ArtistDetailView(artist: artist)
        }
    }
}

private struct ArtistRowView: View {
    let artist: Artist

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(artist.displayName)
                .font(.system(size: 17, weight: .bold))
            if !artist.lifeDates.isEmpty {
                Text(artist.lifeDates)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
