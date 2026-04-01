import SwiftUI

@MainActor
final class BookListViewModel: ObservableObject {
    @Published var books: [Book] = []
    @Published var searchQuery = ""

    private let searchBooksUseCase: SearchBooksUseCase

    init(searchBooksUseCase: SearchBooksUseCase) {
        self.searchBooksUseCase = searchBooksUseCase
    }

    func loadBooks() {
        if searchQuery.isEmpty {
            books = searchBooksUseCase.listAll()
        } else {
            books = searchBooksUseCase.search(searchQuery)
        }
    }
}
