import XCTest
import CucumberSwift
import CucumberSwiftExpressions
@testable import Libratta

extension Cucumber {
    func registerReturnFromListSteps(context: ScenarioContext) {
        When("貸出一覧で書籍 {string} の返却ボタンを押す" as CucumberExpression) { matches, _ in
            let bookTitle = try matches.first(\.string)
            context.ensureReturnUseCase()
            let book = context.bookRepo.findByTitle(bookTitle)
            XCTAssertNotNil(book, "書籍 \(bookTitle) が見つかりません")
            guard let book else { return }
            let loan = context.loanRepo.findActiveByBookId(book.id)
            XCTAssertNotNil(loan, "書籍 \(bookTitle) の貸出記録が見つかりません")
            guard let loan else { return }
            context.returnResult = context.returnUseCase.executeByLoanId(loan.id)
        }

        Then("貸出一覧から書籍 {string} が消える" as CucumberExpression) { matches, _ in
            let bookTitle = try matches.first(\.string)
            let book = context.bookRepo.findByTitle(bookTitle)
            XCTAssertNotNil(book)
            guard let book else { return }
            XCTAssertNil(context.loanRepo.findActiveByBookId(book.id))
            XCTAssertTrue(context.loanRepo.findAll().isEmpty)
        }

        Then("貸出一覧の件数表示が {string} になる" as CucumberExpression) { matches, _ in
            let expected = try matches.first(\.string)
            let count = context.loanRepo.findAll().count
            XCTAssertEqual("\(count)冊 貸し出し中", expected)
        }

        Then("貸出一覧に {string} と表示される" as CucumberExpression) { _, _ in
            XCTAssertTrue(context.loanRepo.findAll().isEmpty)
        }
    }
}
