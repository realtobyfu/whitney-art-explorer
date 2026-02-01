import SwiftUI

@main
struct WhitneyArtExplorerApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                ArtistListView()
                    .tabItem {
                        Label("Artists", systemImage: "person.3")
                    }
                ExhibitionListView()
                    .tabItem {
                        Label("Exhibitions", systemImage: "rectangle.grid.1x2")
                    }
                ArtworkListView()
                    .tabItem {
                        Label("Artworks", systemImage: "paintpalette")
                    }
            }
        }
    }
}
