import XCTest
import CucumberSwift
import CucumberSwiftExpressions

extension Cucumber {
    func registerNavigationUISteps(app: XCUIApplication) {
        Given("トップ画面が表示されている") { _, _ in
            let navBar = app.navigationBars["Libratta"]
            if !navBar.waitForExistence(timeout: 2) {
                LoginPage(app: app).login(
                    email: "librarian@example.com",
                    password: "password"
                )
            }
            TopPage(app: app).verifyDisplayed()
        }

        When("貸し出しカードをタップする") { _, _ in
            TopPage(app: app).tapBorrowingCard()
        }

        // MARK: - Member List

        Then("会員一覧画面が表示される") { _, _ in
            MemberListPage(app: app).verifyDisplayed()
        }

        Then("会員 {string} のカードが表示されている" as CucumberExpression) { matches, _ in
            let name = try matches.first(\.string)
            MemberListPage(app: app).verifyMemberExists(name)
        }

        Given("会員一覧画面が表示されている") { _, _ in
            LoginPage(app: app).login(
                email: "librarian@example.com",
                password: "password"
            )
            TopPage(app: app).tapBorrowingCard()
            MemberListPage(app: app).verifyDisplayed()
        }

        When("会員 {string} のカードをタップする" as CucumberExpression) { matches, _ in
            let name = try matches.first(\.string)
            MemberListPage(app: app).tapMember(name)
        }
    }
}
