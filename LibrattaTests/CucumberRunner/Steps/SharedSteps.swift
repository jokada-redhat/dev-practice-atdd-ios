import XCTest
import CucumberSwift
import CucumberSwiftExpressions
@testable import Libratta

extension Cucumber {
    // swiftlint:disable:next function_body_length
    func registerSharedSteps(context: ScenarioContext) {
        Given("会員 {string} \\(ID: {string}\\) が登録されている" as CucumberExpression) { matches, _ in
            let name = try matches.first(\.string)
            let memberId = try matches.last(\.string)
            try context.memberRepo.save(Member(id: memberId, name: name))
        }

        Given("書籍 {string} が登録されている" as CucumberExpression) { matches, _ in
            let title = try matches.first(\.string)
            try context.bookRepo.save(
                Book(title: title, author: "Author", isbn: UUID().uuidString, publicationYear: 2020)
            )
        }

        Given("会員 {string} が書籍 {string} を既に借りている" as CucumberExpression) { matches, _ in
            let memberId = try matches.first(\.string)
            let bookTitle = try matches.last(\.string)
            if context.bookRepo.findByTitle(bookTitle) == nil {
                try context.bookRepo.save(
                    Book(title: bookTitle, author: "Author", isbn: UUID().uuidString, publicationYear: 2020)
                )
            }
            context.ensureBorrowUseCase()
            _ = context.borrowUseCase.execute(memberId: memberId, bookTitle: bookTitle)
        }

        Then("書籍 {string} は貸出可能である" as CucumberExpression) { matches, _ in
            let title = try matches.first(\.string)
            let book = context.bookRepo.findByTitle(title)
            XCTAssertNotNil(book)
            guard let book else { return }
            XCTAssertNil(context.loanRepo.findActiveByBookId(book.id))
        }

        Then("書籍 {string} は貸出中である" as CucumberExpression) { matches, _ in
            let title = try matches.first(\.string)
            let book = context.bookRepo.findByTitle(title)
            XCTAssertNotNil(book)
            guard let book else { return }
            XCTAssertNotNil(context.loanRepo.findActiveByBookId(book.id))
        }

        Then("会員 {string} の貸出冊数が {int} になる" as CucumberExpression) { matches, _ in
            let memberId = try matches.first(\.string)
            let count = try matches.last(\.int)
            XCTAssertEqual(context.loanRepo.countActiveByMemberId(memberId), count)
        }

        Then("エラーメッセージ {string} が返される" as CucumberExpression) { matches, _ in
            let expected = try matches.first(\.string)
            if let result = context.borrowResult {
                guard case let .error(message) = result else {
                    XCTFail("エラーが返されるべき"); return
                }
                XCTAssertEqual(message, expected)
            } else if let result = context.returnResult {
                guard case let .error(message) = result else {
                    XCTFail("エラーが返されるべき"); return
                }
                XCTAssertEqual(message, expected)
            } else if let result = context.loginResult {
                guard case let .failure(message) = result else {
                    XCTFail("エラーが返されるべき"); return
                }
                XCTAssertEqual(message, expected)
            } else {
                XCTFail("結果が設定されていません")
            }
        }
    }
}
