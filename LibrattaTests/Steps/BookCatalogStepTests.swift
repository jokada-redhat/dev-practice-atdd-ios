import XCTest
@testable import Libratta

/// Feature: 書籍カタログ (book_catalog.feature)
final class BookCatalogStepTests: XCTestCase {
    private var bookRepo: InMemoryBookRepository!

    override func setUp() {
        bookRepo = InMemoryBookRepository()
    }

    private func setupFourBooks() throws {
        try bookRepo.save(Book(title: "The Infinite Library", author: "Jorge Luis Borges", isbn: "978-0142437889", publicationYear: 1941, status: .available))
        try bookRepo.save(Book(title: "Neuromancer", author: "William Gibson", isbn: "978-0441569595", publicationYear: 1984, status: .borrowed))
        try bookRepo.save(Book(title: "The Left Hand of Darkness", author: "Ursula K. Le Guin", isbn: "978-0441478125", publicationYear: 1969, status: .available))
        try bookRepo.save(Book(title: "Foundation", author: "Isaac Asimov", isbn: "978-0553293357", publicationYear: 1951, status: .available))
    }

    func test全書籍を表示する() throws {
        try setupFourBooks()
        let useCase = SearchBooksUseCase(bookRepository: bookRepo)
        XCTAssertEqual(useCase.listAll().count, 4)
    }

    func test貸出可能な書籍のみ表示する() throws {
        try bookRepo.save(Book(title: "The Infinite Library", author: "Jorge Luis Borges", isbn: "978-0142437889", publicationYear: 1941, status: .available))
        try bookRepo.save(Book(title: "Neuromancer", author: "William Gibson", isbn: "978-0441569595", publicationYear: 1984, status: .borrowed))
        try bookRepo.save(Book(title: "The Left Hand of Darkness", author: "Ursula K. Le Guin", isbn: "978-0441478125", publicationYear: 1969, status: .available))

        let useCase = SearchBooksUseCase(bookRepository: bookRepo)
        let books = useCase.filterByStatus(.available)

        XCTAssertEqual(books.count, 2)
        XCTAssertFalse(books.contains { $0.title == "Neuromancer" })
    }

    func test貸出中の書籍のみ表示する() throws {
        try bookRepo.save(Book(title: "The Infinite Library", author: "Jorge Luis Borges", isbn: "978-0142437889", publicationYear: 1941, status: .available))
        try bookRepo.save(Book(title: "Neuromancer", author: "William Gibson", isbn: "978-0441569595", publicationYear: 1984, status: .borrowed))

        let useCase = SearchBooksUseCase(bookRepository: bookRepo)
        let books = useCase.filterByStatus(.borrowed)

        XCTAssertEqual(books.count, 1)
        XCTAssertEqual(books.first?.title, "Neuromancer")
    }

    func test書籍をタイトルで検索する() throws {
        try setupFourBooks()
        let useCase = SearchBooksUseCase(bookRepository: bookRepo)
        let results = useCase.search("Neuromancer")

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.title, "Neuromancer")
    }

    func test書籍を著者名で検索する() throws {
        try bookRepo.save(Book(title: "The Infinite Library", author: "Jorge Luis Borges", isbn: "978-0142437889", publicationYear: 1941))
        try bookRepo.save(Book(title: "The Left Hand of Darkness", author: "Ursula K. Le Guin", isbn: "978-0441478125", publicationYear: 1969))

        let useCase = SearchBooksUseCase(bookRepository: bookRepo)
        let results = useCase.search("Borges")

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.title, "The Infinite Library")
    }

    func test検索結果が0件の場合は空リストが返される() throws {
        try bookRepo.save(Book(title: "The Infinite Library", author: "Jorge Luis Borges", isbn: "978-0142437889", publicationYear: 1941))

        let useCase = SearchBooksUseCase(bookRepository: bookRepo)
        XCTAssertEqual(useCase.search("存在しないタイトル").count, 0)
    }

    func testISBNで書籍を検索する() throws {
        try bookRepo.save(Book(title: "The Infinite Library", author: "Jorge Luis Borges", isbn: "978-0142437889", publicationYear: 1941))
        try bookRepo.save(Book(title: "Neuromancer", author: "William Gibson", isbn: "978-0441569595", publicationYear: 1984))

        let useCase = SearchBooksUseCase(bookRepository: bookRepo)
        let results = useCase.search("978-0142437889")

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.title, "The Infinite Library")
    }

    func testAllフィルタで全書籍が表示される() throws {
        try bookRepo.save(Book(title: "The Infinite Library", author: "Jorge Luis Borges", isbn: "978-0142437889", publicationYear: 1941, status: .available))
        try bookRepo.save(Book(title: "Neuromancer", author: "William Gibson", isbn: "978-0441569595", publicationYear: 1984, status: .borrowed))

        let useCase = SearchBooksUseCase(bookRepository: bookRepo)
        let books = useCase.listAll()

        XCTAssertEqual(books.count, 2)
        XCTAssertTrue(books.contains { $0.title == "The Infinite Library" })
        XCTAssertTrue(books.contains { $0.title == "Neuromancer" })
    }
}
