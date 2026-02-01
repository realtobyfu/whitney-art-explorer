import SwiftUI

struct ExhibitionListView: View {
    @State private var viewModel: ExhibitionListViewModel

    init(apiClient: WhitneyAPIClientProtocol = WhitneyAPIClient()) {
        _viewModel = State(initialValue: ExhibitionListViewModel(apiClient: apiClient))
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.exhibitions.isEmpty && viewModel.isLoading {
                    ProgressView("Loading exhibitions...")
                } else if viewModel.exhibitions.isEmpty && viewModel.error != nil {
                    ContentUnavailableView(
                        "Unable to Load",
                        systemImage: "exclamationmark.triangle",
                        description: Text("Check your connection and try again.")
                    )
                } else if viewModel.exhibitions.isEmpty && !viewModel.isLoading {
                    ContentUnavailableView(
                        "No Exhibitions",
                        systemImage: "rectangle.grid.1x2",
                        description: Text("No exhibitions found.")
                    )
                } else {
                    exhibitionList
                }
            }
            .navigationTitle("Exhibitions")
            .refreshable {
                await viewModel.loadExhibitions()
            }
            .task {
                if viewModel.exhibitions.isEmpty {
                    await viewModel.loadExhibitions()
                }
            }
        }
    }

    private var exhibitionList: some View {
        List {
            ForEach(viewModel.exhibitions) { exhibition in
                NavigationLink(value: exhibition) {
                    ExhibitionRowView(exhibition: exhibition)
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
        .navigationDestination(for: Exhibition.self) { exhibition in
            ExhibitionDetailView(exhibition: exhibition)
        }
    }
}

private struct ExhibitionRowView: View {
    let exhibition: Exhibition

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(exhibition.title)
                .font(.system(size: 17, weight: .bold))
            if !exhibition.dateRange.isEmpty {
                Text(exhibition.dateRange)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
