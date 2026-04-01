import Foundation

public protocol BookRepository: Sendable {
    func save(_ book: Book) throws
    func findById(_ id: String) -> Book?
    func findByTitle(_ title: String) -> Book?
    func findByIsbn(_ isbn: String) -> Book?
    func findAll() -> [Book]
    func search(_ query: String) -> [Book]
    func filterByStatus(_ status: BookStatus) -> [Book]
    func updateStatus(id: String, status: BookStatus) throws
    func delete(_ id: String)
    func clear()
}
