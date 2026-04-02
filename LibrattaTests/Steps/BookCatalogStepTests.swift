import XCTest
@testable import Libratta

/// Feature: 書籍カタログ (book_catalog.feature)
final class BookCatalogStepTests: XCTestCase {
    private var bookRepo: InMemoryBookRepository!
    private var loanRepo: InMemoryLoanRepository!
    private var memberRepo: InMemoryMemberRepository!

    override func setUp() {
        bookRepo = InMemoryBookRepository()
        loanRepo = InMemoryLoanRepository()
        memberRepo = InMemoryMemberRepository()
    }

    private func setupFourBooks() throws {
        try bookRepo.save(Book(title: "The Infinite Library", author: "Jorge Luis Borges", isbn: "978-0142437889", publicationYear: 1941))
        try bookRepo.save(Book(title: "Neuromancer", author: "William Gibson", isbn: "978-0441569595", publicationYear: 1984))
        try bookRepo.save(Book(title: "The Left Hand of Darkness", author: "Ursula K. Le Guin", isbn: "978-0441478125", publicationYear: 1969))
        try bookRepo.save(Book(title: "Foundation", author: "Isaac Asimov", isbn: "978-0553293357", publicationYear: 1951))
    }

    private func markBookAsBorrowed(_ title: String) throws {
        guard let book = bookRepo.findByTitle(title) else {
            XCTFail("書籍 \(title) が見つかりません")
            return
        }
        try memberRepo.save(Member(id: "DA-0001", name: "Dummy"))
        try loanRepo.save(Loan(memberId: "DA-0001", bookId: book.id))
    }

    func testSmoke_全書籍を表示する() throws {
        try setupFourBooks()
        try markBookAsBorrowed("Neuromancer")
        let useCase = SearchBooksUseCase(bookRepository: bookRepo, loanRepository: loanRepo)
        XCTAssertEqual(useCase.listAll().count, 4)
    }

    func test貸出可能な書籍のみ表示する() throws {
        try bookRepo.save(Book(title: "The Infinite Library", author: "Jorge Luis Borges", isbn: "978-0142437889", publicationYear: 1941))
        try bookRepo.save(Book(title: "Neuromancer", author: "William Gibson", isbn: "978-0441569595", publicationYear: 1984))
        try bookRepo.save(Book(title: "The Left Hand of Darkness", author: "Ursula K. Le Guin", isbn: "978-0441478125", publicationYear: 1969))
        try markBookAsBorrowed("Neuromancer")

        let useCase = SearchBooksUseCase(bookRepository: bookRepo, loanRepository: loanRepo)
        let books = useCase.filterByStatus("AVAILABLE")

        XCTAssertEqual(books.count, 2)
        XCTAssertFalse(books.contains { $0.title == "Neuromancer" })
    }

    func test貸出中の書籍のみ表示する() throws {
        try bookRepo.save(Book(title: "The Infinite Library", author: "Jorge Luis Borges", isbn: "978-0142437889", publicationYear: 1941))
        try bookRepo.save(Book(title: "Neuromancer", author: "William Gibson", isbn: "978-0441569595", publicationYear: 1984))
        try markBookAsBorrowed("Neuromancer")

        let useCase = SearchBooksUseCase(bookRepository: bookRepo, loanRepository: loanRepo)
        let books = useCase.filterByStatus("BORROWED")

        XCTAssertEqual(books.count, 1)
        XCTAssertEqual(books.first?.title, "Neuromancer")
    }

    func test書籍をタイトルで検索する() throws {
        try setupFourBooks()
        let useCase = SearchBooksUseCase(bookRepository: bookRepo, loanRepository: loanRepo)
        let results = useCase.search("Neuromancer")

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.title, "Neuromancer")
    }

    func test書籍を著者名で検索する() throws {
        try bookRepo.save(Book(title: "The Infinite Library", author: "Jorge Luis Borges", isbn: "978-0142437889", publicationYear: 1941))
        try bookRepo.save(Book(title: "The Left Hand of Darkness", author: "Ursula K. Le Guin", isbn: "978-0441478125", publicationYear: 1969))

        let useCase = SearchBooksUseCase(bookRepository: bookRepo, loanRepository: loanRepo)
        let results = useCase.search("Borges")

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.title, "The Infinite Library")
    }

    func test検索結果が0件の場合は空リストが返される() throws {
        try bookRepo.save(Book(title: "The Infinite Library", author: "Jorge Luis Borges", isbn: "978-0142437889", publicationYear: 1941))

        let useCase = SearchBooksUseCase(bookRepository: bookRepo, loanRepository: loanRepo)
        XCTAssertEqual(useCase.search("存在しないタイトル").count, 0)
    }

    func testISBNで書籍を検索する() throws {
        try bookRepo.save(Book(title: "The Infinite Library", author: "Jorge Luis Borges", isbn: "978-0142437889", publicationYear: 1941))
        try bookRepo.save(Book(title: "Neuromancer", author: "William Gibson", isbn: "978-0441569595", publicationYear: 1984))

        let useCase = SearchBooksUseCase(bookRepository: bookRepo, loanRepository: loanRepo)
        let results = useCase.search("978-0142437889")

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.title, "The Infinite Library")
    }

    func testAllフィルタで全書籍が表示される() throws {
        try bookRepo.save(Book(title: "The Infinite Library", author: "Jorge Luis Borges", isbn: "978-0142437889", publicationYear: 1941))
        try bookRepo.save(Book(title: "Neuromancer", author: "William Gibson", isbn: "978-0441569595", publicationYear: 1984))
        try markBookAsBorrowed("Neuromancer")

        let useCase = SearchBooksUseCase(bookRepository: bookRepo, loanRepository: loanRepo)
        let books = useCase.listAll()

        XCTAssertEqual(books.count, 2)
        XCTAssertTrue(books.contains { $0.title == "The Infinite Library" })
        XCTAssertTrue(books.contains { $0.title == "Neuromancer" })
    }
}
