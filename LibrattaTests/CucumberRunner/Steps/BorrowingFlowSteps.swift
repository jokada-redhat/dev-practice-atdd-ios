import XCTest
import CucumberSwift
import CucumberSwiftExpressions
@testable import Libratta

extension Cucumber {
    // swiftlint:disable:next function_body_length
    func registerBorrowingFlowSteps(context: ScenarioContext) {
        Given("会員 {string} が {int} 冊借りている状態である" as CucumberExpression) { matches, _ in
            let memberId = try matches.first(\.string)
            let bookCount = try matches.last(\.int)
            context.ensureBorrowUseCase()
            for index in 0..<bookCount {
                let title = "Book \(index + 1)"
                try context.bookRepo.save(
                    Book(title: title, author: "Author", isbn: UUID().uuidString, publicationYear: 2020)
                )
                _ = context.borrowUseCase.execute(memberId: memberId, bookTitle: title)
            }
        }

        When("会員 {string} が書籍 {string} を借りる" as CucumberExpression) { matches, _ in
            let memberId = try matches.first(\.string)
            let bookTitle = try matches.last(\.string)
            context.ensureBorrowUseCase()
            context.borrowResult = context.borrowUseCase.execute(memberId: memberId, bookTitle: bookTitle)
        }

        When("会員 {string} が書籍 {string} を借りようとする" as CucumberExpression) { matches, _ in
            let memberId = try matches.first(\.string)
            let bookTitle = try matches.last(\.string)
            context.ensureBorrowUseCase()
            context.borrowResult = context.borrowUseCase.execute(memberId: memberId, bookTitle: bookTitle)
        }

        When("存在しない会員 {string} が書籍 {string} を借りようとする" as CucumberExpression) { matches, _ in
            let memberId = try matches.first(\.string)
            let bookTitle = try matches.last(\.string)
            context.ensureBorrowUseCase()
            context.borrowResult = context.borrowUseCase.execute(memberId: memberId, bookTitle: bookTitle)
        }

        When("会員 {string} が存在しない書籍を借りようとする" as CucumberExpression) { matches, _ in
            let memberId = try matches.first(\.string)
            context.ensureBorrowUseCase()
            context.borrowResult = context.borrowUseCase.execute(memberId: memberId, bookTitle: "存在しない書籍")
        }

        When("会員 {string} が書籍 {string} を返却する" as CucumberExpression) { matches, _ in
            let memberId = try matches.first(\.string)
            let bookTitle = try matches.last(\.string)
            context.ensureReturnUseCase()
            context.returnResult = context.returnUseCase.execute(memberId: memberId, bookTitle: bookTitle)
        }

        When("会員 {string} が書籍 {string} を返却しようとする" as CucumberExpression) { matches, _ in
            let memberId = try matches.first(\.string)
            let bookTitle = try matches.last(\.string)
            context.ensureReturnUseCase()
            context.returnResult = context.returnUseCase.execute(memberId: memberId, bookTitle: bookTitle)
        }

        Then("貸出記録が作成される") { _, _ in
            XCTAssertEqual(context.loanRepo.findAll().count, 1)
        }

        Then("貸出記録が削除される") { _, _ in
            XCTAssertEqual(context.loanRepo.findAll().count, 0)
        }
    }
}
