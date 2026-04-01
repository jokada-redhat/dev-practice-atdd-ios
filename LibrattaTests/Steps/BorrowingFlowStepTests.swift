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

    private func setupMember(_ name: String, id: String, loanCount: Int = 0) throws {
        try memberRepo.save(Member(id: id, name: name, email: "\(id)@example.com", loanCount: loanCount))
    }

    private func setupBook(_ title: String, status: BookStatus = .available) throws {
        try bookRepo.save(Book(title: title, author: "Author", isbn: UUID().uuidString, publicationYear: 2020, status: status))
    }

    func test会員が書籍を借りる() throws {
        try setupMember("山田太郎", id: "DA-8821")
        try setupBook("The Infinite Library")

        let result = borrowUseCase.execute(memberId: "DA-8821", bookTitle: "The Infinite Library")

        guard case .success = result else {
            XCTFail("貸出が成功するべき")
            return
        }
        XCTAssertEqual(bookRepo.findByTitle("The Infinite Library")?.status, .borrowed)
        XCTAssertEqual(memberRepo.findById("DA-8821")?.loanCount, 1)
        XCTAssertEqual(loanRepo.findAll().count, 1)
    }

    func test既に借りられている書籍は借りられない() throws {
        try setupMember("山田太郎", id: "DA-8821")
        try setupBook("Neuromancer", status: .borrowed)

        let result = borrowUseCase.execute(memberId: "DA-8821", bookTitle: "Neuromancer")

        guard case let .error(message) = result else {
            XCTFail("エラーが返されるべき")
            return
        }
        XCTAssertEqual(message, "この書籍は既に貸出中です")
        XCTAssertEqual(bookRepo.findByTitle("Neuromancer")?.status, .borrowed)
    }

    func test複数の書籍を借りる() throws {
        try setupMember("山田太郎", id: "DA-8821")
        try setupBook("The Infinite Library")
        try setupBook("Foundation")

        _ = borrowUseCase.execute(memberId: "DA-8821", bookTitle: "The Infinite Library")
        _ = borrowUseCase.execute(memberId: "DA-8821", bookTitle: "Foundation")

        XCTAssertEqual(memberRepo.findById("DA-8821")?.loanCount, 2)
        XCTAssertEqual(bookRepo.findByTitle("The Infinite Library")?.status, .borrowed)
        XCTAssertEqual(bookRepo.findByTitle("Foundation")?.status, .borrowed)
    }

    func test会員が書籍を返却する() throws {
        try setupMember("山田太郎", id: "DA-8821")
        try setupBook("The Infinite Library")

        _ = borrowUseCase.execute(memberId: "DA-8821", bookTitle: "The Infinite Library")
        let result = returnUseCase.execute(memberId: "DA-8821", bookTitle: "The Infinite Library")

        guard case let .success(loan) = result else {
            XCTFail("返却が成功するべき")
            return
        }
        XCTAssertEqual(bookRepo.findByTitle("The Infinite Library")?.status, .available)
        XCTAssertEqual(memberRepo.findById("DA-8821")?.loanCount, 0)
        XCTAssertTrue(loan.isReturned)
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
        XCTAssertEqual(bookRepo.findByTitle("The Infinite Library")?.status, .borrowed)

        _ = returnUseCase.execute(memberId: "DA-8821", bookTitle: "The Infinite Library")
        XCTAssertEqual(bookRepo.findByTitle("The Infinite Library")?.status, .available)
        XCTAssertEqual(memberRepo.findById("DA-8821")?.loanCount, 0)
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
