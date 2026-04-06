import XCTest
import CucumberSwift
import CucumberSwiftExpressions

extension Cucumber {
    func registerBorrowingFlowUISteps(app: XCUIApplication) {
        When("書籍 {string} の貸し出しボタンをタップする" as CucumberExpression) { matches, _ in
            let title = try matches.first(\.string)
            BookCatalogPage(app: app).tapBorrowButton(forBook: title)
        }

        When("貸し出し確認ダイアログで「貸し出す」をタップする") { _, _ in
            BookCatalogPage(app: app).confirmBorrowDialog()
        }

        Then("貸し出し確認画面が表示される") { _, _ in
            LoanConfirmationPage(app: app).verifyDisplayed()
        }
    }
}
