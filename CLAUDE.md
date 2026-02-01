# Project: Whitney Explorer

## Quick Reference
- **Platform**: iOS 17+
- **Language**: Swift 5.9
- **UI Framework**: SwiftUI
- **Architecture**: MVVM with @Observable
- **Minimum Deployment**: iOS 17.0
- **Project Generator**: Tuist (NOT raw .xcodeproj)

## Tuist Commands
- Generate project: `tuist generate`
- Edit manifest: `tuist edit`
- Clean: `tuist clean`
- **Never edit .xcodeproj directly** — always edit Project.swift

## xclaude-plugin Integration
This project uses xclaude-plugin for Xcode operations.

**Building:**
- Use `xcode_build` tool from xc-build MCP
- Errors are auto-extracted (up to 10)

**Running:**
- Use `simulator_install` + `simulator_launch` from xc-launch MCP
- Or `simulator_build_and_run` for combined workflow

**UI Verification (if enabled):**
- Use `idb_describe` to query accessibility tree
- Use `simulator_screenshot` to capture current state

## Project Structure
```
WhitneyExplorer/
├── Project.swift              # Tuist manifest (source of truth)
├── Tuist/
│   └── Config.swift
├── Sources/
│   ├── App/
│   │   └── WhitneyExplorerApp.swift
│   ├── Models/
│   │   ├── Artist.swift
│   │   ├── Artwork.swift
│   │   └── APIResponse.swift
│   ├── Services/
│   │   ├── APIClientProtocol.swift
│   │   └── WhitneyAPIClient.swift
│   ├── ViewModels/
│   │   ├── ArtistListViewModel.swift
│   │   └── ArtistDetailViewModel.swift
│   └── Views/
│       ├── ArtistListView.swift
│       ├── ArtistDetailView.swift
│       └── Components/
├── Resources/
│   └── Assets.xcassets
└── Tests/
    └── ViewModelTests/
```

## API Reference
Base URL: `https://whitney.org/api`

| Endpoint                    | Description           |
| --------------------------- | --------------------- |
| `GET /artists`              | Paginated artist list |
| `GET /artists/:id`          | Single artist         |
| `GET /artists/:id/artworks` | Artworks by artist    |
| `GET /artworks/:id`         | Single artwork        |

Pagination: `?page=N`
Search: `?q[name_cont]=searchterm`

## Coding Standards

### Swift Style
- Use `async/await` for networking
- Prefer `@Observable` over `ObservableObject`
- Use `guard` for early exits
- Prefer structs over classes

### SwiftUI Patterns
- Use `@State` for local view state only
- Use `NavigationStack` (not NavigationView)
- Use `@Bindable` for bindings to @Observable objects
- Extract subviews when \> 50 lines

### Testability
- ViewModels depend on protocols, not concrete types
- API client conforms to protocol for mocking
- No singletons — use dependency injection

### Example ViewModel Pattern
```swift
@Observable
final class ArtistListViewModel {
    private let repository: ArtistRepositoryProtocol
    
    var artists: [Artist] = []
    var isLoading = false
    var error: Error?
    
    init(repository: ArtistRepositoryProtocol) {
        self.repository = repository
    }
    
    func loadArtists() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            artists = try await repository.fetchArtists()
        } catch {
            self.error = error
        }
    }
}
```

## DO NOT
- Edit .xcodeproj directly (use Project.swift)
- Use force unwrapping (!) without justification
- Put networking logic in Views
- Create ViewModels that depend on concrete URLSession
- Use deprecated NavigationView
- Forget to run `tuist generate` after changing Project.swift

## Testing
- Use Swift Testing framework (`@Test`, `#expect`)
- Focus on ViewModel logic
- Mock the repository, not URLSession directly
```swift
@Test func loadArtists_setsArtistsOnSuccess() async {
    let mockRepo = MockArtistRepository(artists: [.sample])
    let vm = ArtistListViewModel(repository: mockRepo)
    
    await vm.loadArtists()
    
    #expect(vm.artists.count == 1)
    #expect(vm.isLoading == false)
}
```
