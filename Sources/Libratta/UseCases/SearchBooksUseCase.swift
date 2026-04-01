import Foundation

public final class SearchBooksUseCase: Sendable {
    private let bookRepository: BookRepository
    private let loanRepository: LoanRepository

    public init(bookRepository: BookRepository, loanRepository: LoanRepository) {
        self.bookRepository = bookRepository
        self.loanRepository = loanRepository
    }

    public func listAll() -> [Book] {
        bookRepository.findAll()
    }

    public func search(_ query: String) -> [Book] {
        if query.isEmpty { return listAll() }
        return bookRepository.search(query)
    }

    public func filterByStatus(_ statusString: String) -> [Book] {
        let borrowedBookIds = loanRepository.findBorrowedBookIds()
        switch statusString.uppercased() {
        case "AVAILABLE":
            return bookRepository.findAll().filter { !borrowedBookIds.contains($0.id) }
        case "BORROWED":
            return bookRepository.findAll().filter { borrowedBookIds.contains($0.id) }
        default:
            return listAll()
        }
    }
}
