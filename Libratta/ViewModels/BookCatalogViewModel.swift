import SwiftUI

enum BookFilter: String, CaseIterable {
    case all = "All"
    case available = "Available"
    case borrowed = "Borrowed"
}

@MainActor
final class BookCatalogViewModel: ObservableObject {
    @Published var books: [Book] = []
    @Published var searchQuery = ""
    @Published var selectedFilter: BookFilter = .all
    @Published var borrowResult: String?
    @Published var showBorrowAlert = false

    private let searchBooksUseCase: SearchBooksUseCase
    private let borrowBookUseCase: BorrowBookUseCase
    var selectedMember: Member?

    init(searchBooksUseCase: SearchBooksUseCase, borrowBookUseCase: BorrowBookUseCase) {
        self.searchBooksUseCase = searchBooksUseCase
        self.borrowBookUseCase = borrowBookUseCase
    }

    func loadBooks() {
        if !searchQuery.isEmpty {
            books = searchBooksUseCase.search(searchQuery)
            return
        }

        switch selectedFilter {
        case .all:
            books = searchBooksUseCase.listAll()
        case .available:
            books = searchBooksUseCase.filterByStatus(.available)
        case .borrowed:
            books = searchBooksUseCase.filterByStatus(.borrowed)
        }
    }

    func borrowBook(_ book: Book) {
        guard let member = selectedMember else {
            borrowResult = "会員が選択されていません"
            showBorrowAlert = true
            return
        }

        let result = borrowBookUseCase.execute(memberId: member.id, bookTitle: book.title)
        switch result {
        case .success:
            borrowResult = nil
            loadBooks()
        case let .error(message):
            borrowResult = message
            showBorrowAlert = true
        }
    }
}
