import XCTest
import CucumberSwift
import CucumberSwiftExpressions
@testable import Libratta

extension Cucumber {
    // swiftlint:disable:next function_body_length
    func registerBookManagementSteps(context: ScenarioContext) {
        Given("書籍管理に以下の書籍が登録されている:") { _, step in
            guard let rows = step.dataTable?.rows else { return }
            for row in rows.dropFirst() {
                // swiftlint:disable:next force_try
                try! context.bookRepo.save(
                    Book(title: row[0], author: row[1], isbn: row[2], publicationYear: Int(row[3]) ?? 2020)
                )
            }
        }

        When("書籍一覧を表示する") { _, _ in
            context.ensureSearchBooksUseCase()
            context.bookList = context.searchBooksUseCase.listAll()
        }

        When("書籍一覧で {string} と検索する" as CucumberExpression) { matches, _ in
            let query = try matches.first(\.string)
            context.ensureSearchBooksUseCase()
            context.bookList = context.searchBooksUseCase.search(query)
        }

        When("書籍を登録する:") { _, step in
            guard let rows = step.dataTable?.rows, rows.count >= 2 else { return }
            let row = rows[1]
            let useCase = RegisterBookUseCase(bookRepository: context.bookRepo)
            context.registerBookResult = useCase.execute(
                title: row[0], author: row[1], isbn: row[2], publicationYear: Int(row[3]) ?? 2020
            )
        }

        When("タイトル未入力で書籍を登録しようとする") { _, _ in
            let useCase = RegisterBookUseCase(bookRepository: context.bookRepo)
            context.registerBookResult = useCase.execute(
                title: "", author: "Author", isbn: "978-0000000000", publicationYear: 2020
            )
        }

        When("重複ISBNで書籍を登録しようとする:") { _, step in
            guard let rows = step.dataTable?.rows, rows.count >= 2 else { return }
            let row = rows[1]
            let useCase = RegisterBookUseCase(bookRepository: context.bookRepo)
            context.registerBookResult = useCase.execute(
                title: row[0], author: row[1], isbn: row[2], publicationYear: Int(row[3]) ?? 2020
            )
        }

        Then("書籍一覧に {int} 件表示される" as CucumberExpression) { matches, _ in
            let count = try matches.first(\.int)
            XCTAssertEqual(context.bookList.count, count)
        }

        Then("書籍一覧に書籍 {string} が含まれる" as CucumberExpression) { matches, _ in
            let title = try matches.first(\.string)
            XCTAssertTrue(context.bookList.contains { $0.title == title })
        }

        Then("書籍 {string} が書籍一覧に存在する" as CucumberExpression) { matches, _ in
            let title = try matches.first(\.string)
            XCTAssertNotNil(context.bookRepo.findByTitle(title))
        }

        Then("書籍 {string} の著者が {string} である" as CucumberExpression) { matches, _ in
            let title = try matches.first(\.string)
            let author = try matches.last(\.string)
            let book = context.bookRepo.findByTitle(title)
            XCTAssertEqual(book?.author, author)
        }

        Then("書籍 {string} のISBNが {string} である" as CucumberExpression) { matches, _ in
            let title = try matches.first(\.string)
            let isbn = try matches.last(\.string)
            let book = context.bookRepo.findByTitle(title)
            XCTAssertEqual(book?.isbn, isbn)
        }

        Then("書籍登録エラー {string} が表示される" as CucumberExpression) { matches, _ in
            let expected = try matches.first(\.string)
            guard let result = context.registerBookResult else {
                XCTFail("結果が設定されていません"); return
            }
            switch result {
            case let .validationError(message): XCTAssertEqual(message, expected)
            case let .error(message): XCTAssertEqual(message, expected)
            default: XCTFail("エラーが返されるべき")
            }
        }
    }
}
