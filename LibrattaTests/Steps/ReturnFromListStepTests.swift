import XCTest
@testable import Libratta

/// Feature: 貸出一覧からの返却 (return_from_list.feature)
final class ReturnFromListStepTests: XCTestCase {
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
        try bookRepo.save(Book(title: "The Infinite Library", author: "Author", isbn: "978-1234567890", publicationYear: 2020))
    }

    func test貸出一覧から書籍を返却する() throws {
        try setupBackground()
        _ = borrowUseCase.execute(memberId: "DA-8821", bookTitle: "The Infinite Library")

        let activeLoan = loanRepo.findAllActive().first!
        let result = returnUseCase.executeByLoanId(activeLoan.id)

        guard case let .success(loan) = result else {
            XCTFail("返却が成功するべき")
            return
        }
        XCTAssertEqual(bookRepo.findByTitle("The Infinite Library")?.status, .available)
        XCTAssertEqual(memberRepo.findById("DA-8821")?.loanCount, 0)
        XCTAssertTrue(loan.isReturned)
        XCTAssertTrue(loanRepo.findAllActive().isEmpty)
    }

    func test返却後に貸出中の冊数表示が更新される() throws {
        try setupBackground()
        try bookRepo.save(Book(title: "Foundation", author: "Author", isbn: "978-0553293357", publicationYear: 1951))

        _ = borrowUseCase.execute(memberId: "DA-8821", bookTitle: "The Infinite Library")
        _ = borrowUseCase.execute(memberId: "DA-8821", bookTitle: "Foundation")

        let activeLoan = loanRepo.findAllActive().first { loan in
            bookRepo.findById(loan.bookId)?.title == "The Infinite Library"
        }!

        _ = returnUseCase.executeByLoanId(activeLoan.id)

        XCTAssertEqual(loanRepo.findAllActive().count, 1)
    }

    func test全て返却すると空状態が表示される() throws {
        try setupBackground()
        _ = borrowUseCase.execute(memberId: "DA-8821", bookTitle: "The Infinite Library")

        let activeLoan = loanRepo.findAllActive().first!
        _ = returnUseCase.executeByLoanId(activeLoan.id)

        XCTAssertTrue(loanRepo.findAllActive().isEmpty)
    }
}
