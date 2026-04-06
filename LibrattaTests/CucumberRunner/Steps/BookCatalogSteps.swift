import XCTest
import CucumberSwift
import CucumberSwiftExpressions
@testable import Libratta

extension Cucumber {
    // swiftlint:disable:next function_body_length
    func registerBookCatalogSteps(context: ScenarioContext) {
        Given("以下の書籍が登録されている:") { _, step in
            guard let rows = step.dataTable?.rows else { return }
            for row in rows.dropFirst() {
                // swiftlint:disable:next force_try
                try! context.bookRepo.save(
                    Book(title: row[0], author: row[1], isbn: row[2], publicationYear: Int(row[3]) ?? 2020)
                )
            }
        }

        Given("書籍 {string} が貸出中になっている" as CucumberExpression) { matches, _ in
            let title = try matches.first(\.string)
            guard let book = context.bookRepo.findByTitle(title) else {
                XCTFail("書籍 \(title) が見つかりません"); return
            }
            if context.memberRepo.findById("DA-0001") == nil {
                try context.memberRepo.save(Member(id: "DA-0001", name: "Dummy"))
            }
            try context.loanRepo.save(Loan(memberId: "DA-0001", bookId: book.id))
        }

        When("書籍一覧を取得する") { _, _ in
            context.ensureSearchBooksUseCase()
            context.bookList = context.searchBooksUseCase.listAll()
        }

        When("貸出可能な書籍でフィルタする") { _, _ in
            context.ensureSearchBooksUseCase()
            context.bookList = context.searchBooksUseCase.filterByStatus("AVAILABLE")
        }

        When("貸出中の書籍でフィルタする") { _, _ in
            context.ensureSearchBooksUseCase()
            context.bookList = context.searchBooksUseCase.filterByStatus("BORROWED")
        }

        When("書籍を {string} で検索する" as CucumberExpression) { matches, _ in
            let query = try matches.first(\.string)
            context.ensureSearchBooksUseCase()
            context.searchResults = context.searchBooksUseCase.search(query)
        }

        Then("書籍リストに {int} 件の書籍が含まれている" as CucumberExpression) { matches, _ in
            let count = try matches.first(\.int)
            XCTAssertEqual(context.bookList.count, count)
        }

        Then("書籍リストに {string} が含まれていない" as CucumberExpression) { matches, _ in
            let title = try matches.first(\.string)
            XCTAssertFalse(context.bookList.contains { $0.title == title })
        }

        Then("書籍リストに {string} が含まれている" as CucumberExpression) { matches, _ in
            let title = try matches.first(\.string)
            XCTAssertTrue(context.bookList.contains { $0.title == title })
        }

        Then("検索結果に {int} 件の書籍が含まれている" as CucumberExpression) { matches, _ in
            let count = try matches.first(\.int)
            XCTAssertEqual(context.searchResults.count, count)
        }

        Then("書籍検索結果に {string} が含まれている" as CucumberExpression) { matches, _ in
            let title = try matches.first(\.string)
            XCTAssertTrue(context.searchResults.contains { $0.title == title })
        }
    }
}
