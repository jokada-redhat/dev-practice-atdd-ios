import XCTest
@testable import Libratta

/// Feature: 書籍管理 (book_management.feature)
final class BookManagementStepTests: XCTestCase {
    private var bookRepo: InMemoryBookRepository!
    private var loanRepo: InMemoryLoanRepository!

    override func setUp() {
        bookRepo = InMemoryBookRepository()
        loanRepo = InMemoryLoanRepository()
    }

    func test登録済みの書籍が一覧表示される() throws {
        try bookRepo.save(Book(title: "The Infinite Library", author: "Jorge Borges", isbn: "978-1234567890", publicationYear: 2020))
        try bookRepo.save(Book(title: "Foundation", author: "Isaac Asimov", isbn: "978-0553293357", publicationYear: 1951))
        try bookRepo.save(Book(title: "Neuromancer", author: "William Gibson", isbn: "978-0441569595", publicationYear: 1984))

        let useCase = SearchBooksUseCase(bookRepository: bookRepo, loanRepository: loanRepo)
        XCTAssertEqual(useCase.listAll().count, 3)
    }

    func test書籍名で部分一致検索できる() throws {
        try bookRepo.save(Book(title: "The Infinite Library", author: "Jorge Borges", isbn: "978-1234567890", publicationYear: 2020))
        try bookRepo.save(Book(title: "Foundation", author: "Isaac Asimov", isbn: "978-0553293357", publicationYear: 1951))

        let useCase = SearchBooksUseCase(bookRepository: bookRepo, loanRepository: loanRepo)
        let results = useCase.search("Infinite")

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.title, "The Infinite Library")
    }

    func testISBNで検索できる() throws {
        try bookRepo.save(Book(title: "The Infinite Library", author: "Jorge Borges", isbn: "978-1234567890", publicationYear: 2020))
        try bookRepo.save(Book(title: "Foundation", author: "Isaac Asimov", isbn: "978-0553293357", publicationYear: 1951))

        let useCase = SearchBooksUseCase(bookRepository: bookRepo, loanRepository: loanRepo)
        let results = useCase.search("978-0553")

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.title, "Foundation")
    }

    func test著者名で検索できる() throws {
        try bookRepo.save(Book(title: "The Infinite Library", author: "Jorge Borges", isbn: "978-1234567890", publicationYear: 2020))
        try bookRepo.save(Book(title: "Foundation", author: "Isaac Asimov", isbn: "978-0553293357", publicationYear: 1951))

        let useCase = SearchBooksUseCase(bookRepository: bookRepo, loanRepository: loanRepo)
        XCTAssertEqual(useCase.search("Asimov").count, 1)
    }

    func test新しい書籍を登録できる() {
        let useCase = RegisterBookUseCase(bookRepository: bookRepo)
        let result = useCase.execute(title: "Dune", author: "Frank Herbert", isbn: "978-0441172719", publicationYear: 1965)

        guard case let .success(book) = result else {
            XCTFail("登録が成功するべき")
            return
        }
        XCTAssertEqual(book.title, "Dune")
        XCTAssertEqual(book.author, "Frank Herbert")
        XCTAssertEqual(book.isbn, "978-0441172719")
    }

    func testタイトル未入力では登録できない() {
        let useCase = RegisterBookUseCase(bookRepository: bookRepo)
        let result = useCase.execute(title: "", author: "Author", isbn: "978-0000000000", publicationYear: 2020)

        guard case let .validationError(message) = result else {
            XCTFail("バリデーションエラーが発生するべき")
            return
        }
        XCTAssertEqual(message, "タイトルを入力してください")
    }

    func testISBN重複では登録できない() throws {
        try bookRepo.save(Book(title: "The Infinite Library", author: "Jorge Borges", isbn: "978-1234567890", publicationYear: 2020))

        let useCase = RegisterBookUseCase(bookRepository: bookRepo)
        let result = useCase.execute(title: "Another", author: "Author", isbn: "978-1234567890", publicationYear: 2021)

        guard case let .error(message) = result else {
            XCTFail("エラーが返されるべき")
            return
        }
        XCTAssertEqual(message, "このISBNは既に登録されています")
    }
}
