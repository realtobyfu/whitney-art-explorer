import Foundation

struct Artist: Codable, Identifiable, Hashable {
    let id: Int
    let displayName: String
    let sortName: String
    let displayDate: String?
    let beginDate: String?
    let endDate: String?
    let biography: String?
    let onView: Bool

    var lifeDates: String {
        guard let begin = beginDate, !begin.isEmpty, begin != "0" else {
            return ""
        }
        if let end = endDate, !end.isEmpty, end != "0" {
            return "\(begin)–\(end)"
        }
        return "\(begin)–present"
    }
}
