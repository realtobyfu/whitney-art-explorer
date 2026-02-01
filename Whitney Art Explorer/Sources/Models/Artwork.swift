import Foundation

struct Artwork: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let displayDate: String?
    let medium: String?
    let dimensions: String?
    let creditLine: String?
    let displayArtistText: String?
    let images: [ArtworkImage]
    let aiAltText: String?

    var imageURL: URL? {
        guard let urlString = images.first?.url else { return nil }
        return URL(string: urlString)
    }

    init(id: Int, title: String, displayDate: String?, medium: String?,
         dimensions: String?, creditLine: String?, displayArtistText: String?,
         images: [ArtworkImage], aiAltText: String?) {
        self.id = id
        self.title = title
        self.displayDate = displayDate
        self.medium = medium
        self.dimensions = dimensions
        self.creditLine = creditLine
        self.displayArtistText = displayArtistText
        self.images = images
        self.aiAltText = aiAltText
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? "(No Title)"
        displayDate = try container.decodeIfPresent(String.self, forKey: .displayDate)
        medium = try container.decodeIfPresent(String.self, forKey: .medium)
        dimensions = try container.decodeIfPresent(String.self, forKey: .dimensions)
        creditLine = try container.decodeIfPresent(String.self, forKey: .creditLine)
        displayArtistText = try container.decodeIfPresent(String.self, forKey: .displayArtistText)
        images = try container.decodeIfPresent([ArtworkImage].self, forKey: .images) ?? []
        aiAltText = try container.decodeIfPresent(String.self, forKey: .aiAltText)
    }
}

struct ArtworkImage: Codable, Hashable {
    let id: Int
    let url: String
}
