import XCTest
import CucumberSwift
import CucumberSwiftExpressions

extension Cucumber {
    func registerBookCatalogUISteps(app: XCUIApplication) {
        Then("書籍カタログ画面が表示される") { _, _ in
            BookCatalogPage(app: app).verifyDisplayed()
        }

        Then("選択中メンバー {string} が表示されている" as CucumberExpression) { matches, _ in
            let name = try matches.first(\.string)
            BookCatalogPage(app: app).verifySelectedMember(name)
        }

        Given("書籍カタログ画面が会員 {string} で表示されている" as CucumberExpression) { matches, _ in
            let memberName = try matches.first(\.string)
            LoginPage(app: app).login(
                email: "librarian@example.com",
                password: "password"
            )
            TopPage(app: app).tapBorrowingCard()
            MemberListPage(app: app).tapMember(memberName)
            BookCatalogPage(app: app).verifyDisplayed()
        }

        Then("書籍 {string} のカードが表示されている" as CucumberExpression) { matches, _ in
            let title = try matches.first(\.string)
            BookCatalogPage(app: app).verifyBookExists(title)
        }

        Then("書籍 {string} のカードが表示されていない" as CucumberExpression) { matches, _ in
            let title = try matches.first(\.string)
            BookCatalogPage(app: app).verifyBookNotExists(title)
        }

        When("{string} フィルタボタンをタップする" as CucumberExpression) { matches, _ in
            let filter = try matches.first(\.string)
            BookCatalogPage(app: app).tapFilter(filter)
        }
    }
}
