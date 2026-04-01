import Foundation

public final class InMemoryBookRepository: BookRepository, @unchecked Sendable {
    private var books: [String: Book] = [:]

    public init() {}

    public func save(_ book: Book) throws {
        if let existing = findByIsbn(book.isbn), existing.id != book.id {
            throw RepositoryError.duplicateIsbn
        }
        books[book.id] = book
    }

    public func findById(_ id: String) -> Book? {
        books[id]
    }

    public func findByTitle(_ title: String) -> Book? {
        books.values.first { $0.title == title }
    }

    public func findByIsbn(_ isbn: String) -> Book? {
        books.values.first { $0.isbn == isbn }
    }

    public func findAll() -> [Book] {
        Array(books.values)
    }

    public func search(_ query: String) -> [Book] {
        let lowered = query.lowercased()
        return books.values.filter {
            $0.title.lowercased().contains(lowered) ||
            $0.author.lowercased().contains(lowered) ||
            $0.isbn.lowercased().contains(lowered)
        }
    }

    public func filterByStatus(_ status: BookStatus) -> [Book] {
        books.values.filter { $0.status == status }
    }

    public func updateStatus(id: String, status: BookStatus) throws {
        guard var book = books[id] else {
            throw RepositoryError.notFound
        }
        book.status = status
        books[id] = book
    }

    public func delete(_ id: String) {
        books.removeValue(forKey: id)
    }

    public func clear() {
        books.removeAll()
    }
}
