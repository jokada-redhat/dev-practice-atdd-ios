import XCTest
import CucumberSwift
import CucumberSwiftExpressions
@testable import Libratta

extension Cucumber {
    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func registerReturnBookSteps(context: ScenarioContext) {
        Given("返却用に会員 {string} \\(ID: {string}\\) が登録されている" as CucumberExpression) { matches, _ in
            let name = try matches.first(\.string)
            let memberId = try matches.last(\.string)
            try context.memberRepo.save(Member(id: memberId, name: name))
        }

        Given("返却用に以下の書籍が貸出されている:") { _, step in
            guard let rows = step.dataTable?.rows else { return }
            context.ensureBorrowUseCase()
            for row in rows.dropFirst() {
                let memberId = row[0]
                let bookTitle = row[1]
                let isbn = row[2]
                // swiftlint:disable:next force_try
                try! context.bookRepo.save(
                    Book(title: bookTitle, author: "Author", isbn: isbn, publicationYear: 2020)
                )
                _ = context.borrowUseCase.execute(memberId: memberId, bookTitle: bookTitle)
            }
        }

        When("返却画面を開く") { _, _ in
            context.loanSearchResults = context.loanRepo.findAll()
        }

        When("検索ボックスに {string} と入力する" as CucumberExpression) { matches, _ in
            let query = try matches.first(\.string)
            context.loanSearchResults = context.loanRepo.findAll().filter { loan in
                if let book = context.bookRepo.findById(loan.bookId) {
                    if book.title.lowercased().contains(query.lowercased()) { return true }
                    if book.isbn.contains(query) { return true }
                }
                if let member = context.memberRepo.findById(loan.memberId) {
                    if member.name.contains(query) { return true }
                    if member.id.contains(query) { return true }
                }
                return false
            }
        }

        When("絞り込み結果から書籍 {string} を返却する" as CucumberExpression) { matches, _ in
            let bookTitle = try matches.first(\.string)
            context.ensureReturnUseCase()
            let book = context.bookRepo.findByTitle(bookTitle)
            XCTAssertNotNil(book)
            guard let book else { return }
            let loan = context.loanSearchResults.first { $0.bookId == book.id }
            XCTAssertNotNil(loan)
            guard let loan else { return }
            context.returnResult = context.returnUseCase.execute(
                memberId: loan.memberId, bookTitle: bookTitle
            )
        }

        When("検索ボックスをクリアする") { _, _ in
            context.loanSearchResults = context.loanRepo.findAll()
        }

        Then("貸出一覧に {int} 件表示される" as CucumberExpression) { matches, _ in
            let count = try matches.first(\.int)
            XCTAssertEqual(context.loanSearchResults.count, count)
        }

        Then("貸出一覧に書籍 {string} が表示される" as CucumberExpression) { matches, _ in
            let bookTitle = try matches.first(\.string)
            let book = context.bookRepo.findByTitle(bookTitle)
            XCTAssertNotNil(book)
            guard let book else { return }
            XCTAssertTrue(context.loanSearchResults.contains { $0.bookId == book.id })
        }

        Then("返却後の書籍 {string} は貸出可能である" as CucumberExpression) { matches, _ in
            let title = try matches.first(\.string)
            let book = context.bookRepo.findByTitle(title)
            XCTAssertNotNil(book)
            guard let book else { return }
            XCTAssertNil(context.loanRepo.findActiveByBookId(book.id))
        }

        Then("返却後の会員 {string} の貸出冊数が {int} である" as CucumberExpression) { matches, _ in
            let memberId = try matches.first(\.string)
            let count = try matches.last(\.int)
            XCTAssertEqual(context.loanRepo.countActiveByMemberId(memberId), count)
        }
    }
}
