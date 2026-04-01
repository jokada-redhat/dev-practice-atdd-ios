import XCTest
@testable import Libratta

/// Feature: 貸し出しフロー (borrowing_flow.feature)
final class BorrowingFlowStepTests: XCTestCase {
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

    private func setupMember(_ name: String, id: String) throws {
        try memberRepo.save(Member(id: id, name: name))
    }

    private func setupBook(_ title: String) throws {
        try bookRepo.save(Book(title: title, author: "Author", isbn: UUID().uuidString, publicationYear: 2020))
    }

    func test会員が書籍を借りる() throws {
        try setupMember("山田太郎", id: "DA-8821")
        try setupBook("The Infinite Library")

        let result = borrowUseCase.execute(memberId: "DA-8821", bookTitle: "The Infinite Library")

        guard case .success = result else {
            XCTFail("貸出が成功するべき")
            return
        }
        let book = bookRepo.findByTitle("The Infinite Library")!
        XCTAssertNotNil(loanRepo.findActiveByBookId(book.id))
        XCTAssertEqual(loanRepo.countActiveByMemberId("DA-8821"), 1)
        XCTAssertEqual(loanRepo.findAll().count, 1)
    }

    func test既に借りられている書籍は借りられない() throws {
        try setupMember("山田太郎", id: "DA-8821")
        try setupMember("田中次郎", id: "DA-1156")
        try setupBook("Neuromancer")
        _ = borrowUseCase.execute(memberId: "DA-1156", bookTitle: "Neuromancer")

        let result = borrowUseCase.execute(memberId: "DA-8821", bookTitle: "Neuromancer")

        guard case let .error(message) = result else {
            XCTFail("エラーが返されるべき")
            return
        }
        XCTAssertEqual(message, "この書籍は既に貸出中です")
    }

    func test複数の書籍を借りている会員の貸出冊数が正しい() throws {
        try setupMember("山田太郎", id: "DA-8821")
        try setupBook("Book A")
        try setupBook("Book B")
        _ = borrowUseCase.execute(memberId: "DA-8821", bookTitle: "Book A")
        _ = borrowUseCase.execute(memberId: "DA-8821", bookTitle: "Book B")

        XCTAssertEqual(loanRepo.countActiveByMemberId("DA-8821"), 2)
    }

    func test会員が書籍を返却する() throws {
        try setupMember("山田太郎", id: "DA-8821")
        try setupBook("The Infinite Library")

        _ = borrowUseCase.execute(memberId: "DA-8821", bookTitle: "The Infinite Library")
        let loanCountBefore = loanRepo.findAll().count
        XCTAssertEqual(loanCountBefore, 1)

        let result = returnUseCase.execute(memberId: "DA-8821", bookTitle: "The Infinite Library")

        guard case .success = result else {
            XCTFail("返却が成功するべき")
            return
        }
        let book = bookRepo.findByTitle("The Infinite Library")!
        XCTAssertNil(loanRepo.findActiveByBookId(book.id))
        XCTAssertEqual(loanRepo.countActiveByMemberId("DA-8821"), 0)
        XCTAssertEqual(loanRepo.findAll().count, 0)
    }

    func test借りていない書籍は返却できない() throws {
        try setupMember("山田太郎", id: "DA-8821")
        try setupBook("The Infinite Library")

        let result = returnUseCase.execute(memberId: "DA-8821", bookTitle: "The Infinite Library")

        guard case let .error(message) = result else {
            XCTFail("エラーが返されるべき")
            return
        }
        XCTAssertEqual(message, "この書籍は貸し出されていません")
    }

    func test存在しない会員IDで書籍を借りようとする() throws {
        try setupBook("The Infinite Library")

        let result = borrowUseCase.execute(memberId: "DA-9999", bookTitle: "The Infinite Library")

        guard case let .error(message) = result else {
            XCTFail("エラーが返されるべき")
            return
        }
        XCTAssertEqual(message, "会員が見つかりません")
    }

    func test存在しない書籍を借りようとする() throws {
        try setupMember("山田太郎", id: "DA-8821")

        let result = borrowUseCase.execute(memberId: "DA-8821", bookTitle: "存在しない書籍")

        guard case let .error(message) = result else {
            XCTFail("エラーが返されるべき")
            return
        }
        XCTAssertEqual(message, "書籍が見つかりません")
    }

    func test書籍を借りて返却すると再び貸出可能になる() throws {
        try setupMember("山田太郎", id: "DA-8821")
        try setupBook("The Infinite Library")

        _ = borrowUseCase.execute(memberId: "DA-8821", bookTitle: "The Infinite Library")
        let book = bookRepo.findByTitle("The Infinite Library")!
        XCTAssertNotNil(loanRepo.findActiveByBookId(book.id))

        _ = returnUseCase.execute(memberId: "DA-8821", bookTitle: "The Infinite Library")
        XCTAssertNil(loanRepo.findActiveByBookId(book.id))
        XCTAssertEqual(loanRepo.countActiveByMemberId("DA-8821"), 0)
    }

    func test別の会員が借りている書籍は返却できない() throws {
        try setupMember("山田太郎", id: "DA-8821")
        try setupMember("田中次郎", id: "DA-1156")
        try setupBook("The Infinite Library")

        _ = borrowUseCase.execute(memberId: "DA-8821", bookTitle: "The Infinite Library")
        let result = returnUseCase.execute(memberId: "DA-1156", bookTitle: "The Infinite Library")

        guard case let .error(message) = result else {
            XCTFail("エラーが返されるべき")
            return
        }
        XCTAssertEqual(message, "この書籍は別の会員が借りています")
    }
}
