import UIKit

final class Cache<Key: Hashable, Value> {
    private let wrapped = NSCache<WrappedKey, Entry>()

    subscript(key: Key) -> Value? {
        get { wrapped.object(forKey: WrappedKey(key))?.value }
        set {
            if let value = newValue {
                wrapped.setObject(Entry(value), forKey: WrappedKey(key))
            } else {
                wrapped.removeObject(forKey: WrappedKey(key))
            }
        }
    }
}

private extension Cache {
    final class WrappedKey: NSObject {
        let key: Key

        init(_ key: Key) { self.key = key }

        override var hash: Int { key.hashValue }

        override func isEqual(_ object: Any?) -> Bool {
            guard let other = object as? WrappedKey else { return false }
            return key == other.key
        }
    }

    final class Entry {
        let value: Value
        init(_ value: Value) { self.value = value }
    }
}

actor ImageLoader {
    static let shared = ImageLoader()

    private let cache = Cache<URL, UIImage>()
    private var inFlightTasks: [URL: Task<UIImage, Error>] = [:]

    func image(from url: URL) async throws -> UIImage {
        if let cached = cache[url] {
            return cached
        }

        if let existing = inFlightTasks[url] {
            return try await existing.value
        }

        let task = Task<UIImage, Error> {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else {
                throw URLError(.cannotDecodeContentData)
            }
            return image
        }

        inFlightTasks[url] = task

        do {
            let image = try await task.value
            cache[url] = image
            inFlightTasks[url] = nil
            return image
        } catch {
            inFlightTasks[url] = nil
            throw error
        }
    }
}
