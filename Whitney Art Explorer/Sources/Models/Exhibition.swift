import Foundation

struct Exhibition: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let startTime: String?
    let endTime: String?
    let dateOverride: String?
    let url: String?
    let primaryText: String?

    var dateRange: String {
        if let override = dateOverride, !override.isEmpty {
            return override
        }
        guard let start = startTime else { return "" }
        let startFormatted = Self.formatDate(start)
        if let end = endTime {
            let endFormatted = Self.formatDate(end)
            return "\(startFormatted) – \(endFormatted)"
        }
        return startFormatted
    }

    private static let isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    private static let displayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()

    private static func formatDate(_ iso: String) -> String {
        if let date = isoFormatter.date(from: iso) {
            return displayFormatter.string(from: date)
        }
        // Try without fractional seconds
        let fallback = ISO8601DateFormatter()
        if let date = fallback.date(from: iso) {
            return displayFormatter.string(from: date)
        }
        return iso
    }
}
