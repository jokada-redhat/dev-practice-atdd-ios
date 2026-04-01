import Foundation

public protocol BookRepository: Sendable {
    func save(_ book: Book) throws
    func findById(_ id: String) -> Book?
    func findByTitle(_ title: String) -> Book?
    func findAll() -> [Book]
    func search(_ query: String) -> [Book]
    func delete(_ id: String)
    func clear()
}
