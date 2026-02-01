import Foundation

struct APIResponse<T: Codable>: Codable {
    let data: [APIObject<T>]
    let meta: Meta?
    let links: PaginationLinks?
}

struct SingleAPIResponse<T: Codable>: Codable {
    let data: APIObject<T>
}

struct APIObject<T: Codable>: Codable {
    let id: String
    let type: String
    let attributes: T
}

struct Meta: Codable {
    let total: Int
}

struct PaginationLinks: Codable {
    let next: String?
    let prev: String?
    let first: String?
    let last: String?
}
