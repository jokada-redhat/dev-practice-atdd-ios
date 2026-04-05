import Foundation

public final class InMemoryBookRepository: BookRepository, @unchecked Sendable {
    private var books: [String: Book] = [:]

    public init() {}

    public func save(_ book: Book) throws {
        if let existing = books.values.first(where: { $0.isbn == book.isbn }),
           existing.id != book.id {
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

    public func findAll() -> [Book] {
        Array(books.values).sorted { $0.id < $1.id }
    }

    public func search(_ query: String) -> [Book] {
        let lowered = query.lowercased()
        return books.values.filter {
            $0.title.lowercased().contains(lowered) ||
            $0.author.lowercased().contains(lowered) ||
            $0.isbn.lowercased().contains(lowered)
        }
    }

    public func delete(_ id: String) {
        books.removeValue(forKey: id)
    }

    public func clear() {
        books.removeAll()
    }
}
