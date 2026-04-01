import XCTest
@testable import Libratta

/// Feature: 貸出一覧からの書籍返却 (return_book.feature)
final class ReturnBookStepTests: XCTestCase {
    private var memberRepo: InMemoryMemberRepository!
    private var bookRepo: InMemoryBookRepository!
    private var loanRepo: InMemoryLoanRepository!
    private var borrowUseCase: BorrowBookUseCase!
    private var returnUseCase: ReturnBookUseCase!

    override func setUp() {
        memberRepo = InMemoryMemberRepository()
        bookRepo = InMemoryBookRepository()
        loanRepo = InMemoryLoanRepository()
        borrowUseCase = BorrowBookUseCase(memberRepository: memberRepo, bookRepository: bookRepo, loanRepository: loanRepo)
        returnUseCase = ReturnBookUseCase(memberRepository: memberRepo, bookRepository: bookRepo, loanRepository: loanRepo)
    }

    private func setupBackground() throws {
        try memberRepo.save(Member(id: "DA-8821", name: "山田太郎", email: "yamada@example.com"))
        try memberRepo.save(Member(id: "DA-1156", name: "田中次郎", email: "tanaka@example.com"))
        try bookRepo.save(Book(title: "The Infinite Library", author: "Author", isbn: "978-1234567890", publicationYear: 2020))
        try bookRepo.save(Book(title: "Foundation", author: "Author", isbn: "978-0553293357", publicationYear: 1951))
        try bookRepo.save(Book(title: "Neuromancer", author: "Author", isbn: "978-0441569595", publicationYear: 1984))

        _ = borrowUseCase.execute(memberId: "DA-8821", bookTitle: "The Infinite Library")
        _ = borrowUseCase.execute(memberId: "DA-8821", bookTitle: "Foundation")
        _ = borrowUseCase.execute(memberId: "DA-1156", bookTitle: "Neuromancer")
    }

    func test全ての貸出中書籍が一覧表示される() throws {
        try setupBackground()
        XCTAssertEqual(loanRepo.findAllActive().count, 3)
    }

    func test書籍名で部分一致検索できる() throws {
        try setupBackground()
        let allLoans = loanRepo.findAllActive()
        let results = allLoans.filter { loan in
            guard let book = bookRepo.findById(loan.bookId) else { return false }
            return book.title.lowercased().contains("infinite")
        }
        XCTAssertEqual(results.count, 1)
    }

    func testISBNで検索できる() throws {
        try setupBackground()
        let allLoans = loanRepo.findAllActive()
        let results = allLoans.filter { loan in
            guard let book = bookRepo.findById(loan.bookId) else { return false }
            return book.isbn.contains("978-0553")
        }
        XCTAssertEqual(results.count, 1)
    }

    func test会員名で検索できる() throws {
        try setupBackground()
        let allLoans = loanRepo.findAllActive()
        let results = allLoans.filter { loan in
            guard let member = memberRepo.findById(loan.memberId) else { return false }
            return member.name.contains("田中")
        }
        XCTAssertEqual(results.count, 1)
    }

    func test会員IDで検索できる() throws {
        try setupBackground()
        let results = loanRepo.findAllActive().filter { $0.memberId == "DA-8821" }
        XCTAssertEqual(results.count, 2)
    }

    func test検索結果から書籍を返却できる() throws {
        try setupBackground()
        let result = returnUseCase.execute(memberId: "DA-8821", bookTitle: "The Infinite Library")

        guard case .success = result else {
            XCTFail("返却が成功するべき")
            return
        }
        XCTAssertEqual(bookRepo.findByTitle("The Infinite Library")?.status, .available)
        XCTAssertEqual(memberRepo.findById("DA-8821")?.loanCount, 1)
    }
}
