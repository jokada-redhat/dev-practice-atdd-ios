import XCTest
import CucumberSwift
import CucumberSwiftExpressions

extension Cucumber: StepImplementation {
    public var bundle: Bundle {
        class Findme { }
        return Bundle(for: Findme.self)
    }

    public func setupSteps() {
        let app = XCUIApplication()

        BeforeScenario { _ in
            app.terminate()
            app.launch()
        }

        // MARK: - Login Steps

        Given("未ログイン状態になっている") { _, _ in
        }

        When("以下の認証情報でログインする") { _, step in
            let row = step.dataTable!.rows[1]
            LoginPage(app: app).login(email: row[0], password: row[1])
        }

        Then("表示名 {string} がトップページに表示されている" as CucumberExpression) { matches, _ in
            let name = try matches.first(\.string)
            TopPage(app: app).verifyDisplayName(name)
        }

        let verifyLogoutButton: (CucumberSwiftExpressions.Match, Step) throws -> Void = { _, _ in
            TopPage(app: app).verifyLogoutButtonExists()
        }
        Then("ログアウトボタンが表示されている" as CucumberExpression, callback: verifyLogoutButton)
        And("ログアウトボタンが表示されている" as CucumberExpression, callback: verifyLogoutButton)

        Then("エラーメッセージ {string} が表示されている" as CucumberExpression) { matches, _ in
            let message = try matches.first(\.string)
            LoginPage(app: app).verifyError(message)
        }

        // MARK: - Navigation Steps

        Given("トップ画面が表示されている") { _, _ in
            LoginPage(app: app).login(
                email: "librarian@example.com",
                password: "password"
            )
            TopPage(app: app).verifyDisplayed()
        }

        When("貸し出しカードをタップする") { _, _ in
            TopPage(app: app).tapBorrowingCard()
        }

        // MARK: - Member List Steps

        Then("会員一覧画面が表示される") { _, _ in
            MemberListPage(app: app).verifyDisplayed()
        }

        let verifyMemberExists: (CucumberSwiftExpressions.Match, Step) throws -> Void = { matches, _ in
            let name = try matches.first(\.string)
            MemberListPage(app: app).verifyMemberExists(name)
        }
        Then("会員 {string} のカードが表示されている" as CucumberExpression, callback: verifyMemberExists)
        And("会員 {string} のカードが表示されている" as CucumberExpression, callback: verifyMemberExists)

        Given("会員一覧画面が表示されている") { _, _ in
            LoginPage(app: app).login(
                email: "librarian@example.com",
                password: "password"
            )
            TopPage(app: app).tapBorrowingCard()
            MemberListPage(app: app).verifyDisplayed()
        }

        let tapMember: (CucumberSwiftExpressions.Match, Step) throws -> Void = { matches, _ in
            let name = try matches.first(\.string)
            MemberListPage(app: app).tapMember(name)
        }
        When("会員 {string} のカードをタップする" as CucumberExpression, callback: tapMember)
        And("会員 {string} のカードをタップする" as CucumberExpression, callback: tapMember)

        // MARK: - Book Catalog Steps

        Then("書籍カタログ画面が表示される") { _, _ in
            BookCatalogPage(app: app).verifyDisplayed()
        }

        let verifySelectedMember: (CucumberSwiftExpressions.Match, Step) throws -> Void = { matches, _ in
            let name = try matches.first(\.string)
            BookCatalogPage(app: app).verifySelectedMember(name)
        }
        Then("選択中メンバー {string} が表示されている" as CucumberExpression, callback: verifySelectedMember)
        And("選択中メンバー {string} が表示されている" as CucumberExpression, callback: verifySelectedMember)

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

        let verifyBookExists: (CucumberSwiftExpressions.Match, Step) throws -> Void = { matches, _ in
            let title = try matches.first(\.string)
            BookCatalogPage(app: app).verifyBookExists(title)
        }
        Then("書籍 {string} のカードが表示されている" as CucumberExpression, callback: verifyBookExists)
        And("書籍 {string} のカードが表示されている" as CucumberExpression, callback: verifyBookExists)

        let verifyBookNotExists: (CucumberSwiftExpressions.Match, Step) throws -> Void = { matches, _ in
            let title = try matches.first(\.string)
            BookCatalogPage(app: app).verifyBookNotExists(title)
        }
        Then("書籍 {string} のカードが表示されていない" as CucumberExpression, callback: verifyBookNotExists)
        And("書籍 {string} のカードが表示されていない" as CucumberExpression, callback: verifyBookNotExists)

        When("{string} フィルタボタンをタップする" as CucumberExpression) { matches, _ in
            let filter = try matches.first(\.string)
            BookCatalogPage(app: app).tapFilter(filter)
        }

        // MARK: - Borrowing Flow Steps

        let tapBorrowButton: (CucumberSwiftExpressions.Match, Step) throws -> Void = { matches, _ in
            let title = try matches.first(\.string)
            BookCatalogPage(app: app).tapBorrowButton(forBook: title)
        }
        When("書籍 {string} の貸し出しボタンをタップする" as CucumberExpression, callback: tapBorrowButton)
        And("書籍 {string} の貸し出しボタンをタップする" as CucumberExpression, callback: tapBorrowButton)

        let confirmBorrowDialog: (CucumberSwiftExpressions.Match, Step) throws -> Void = { _, _ in
            BookCatalogPage(app: app).confirmBorrowDialog()
        }
        When("貸し出し確認ダイアログで「貸し出す」をタップする" as CucumberExpression, callback: confirmBorrowDialog)
        And("貸し出し確認ダイアログで「貸し出す」をタップする" as CucumberExpression, callback: confirmBorrowDialog)

        Then("貸し出し確認画面が表示される") { _, _ in
            LoanConfirmationPage(app: app).verifyDisplayed()
        }
    }
}
