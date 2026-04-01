import Foundation

public final class SearchBooksUseCase: Sendable {
    private let bookRepository: BookRepository

    public init(bookRepository: BookRepository) {
        self.bookRepository = bookRepository
    }

    public func listAll() -> [Book] {
        bookRepository.findAll()
    }

    public func search(_ query: String) -> [Book] {
        bookRepository.search(query)
    }

    public func filterByStatus(_ status: BookStatus) -> [Book] {
        bookRepository.filterByStatus(status)
    }
}
