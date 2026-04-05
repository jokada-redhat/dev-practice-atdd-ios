import XCTest
import CucumberSwift

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

        When("正しい認証情報でログインする") { _, _ in
            LoginPage(app: app).login(
                email: "test@example.com",
                password: "pass123"
            )
        }

        When("誤ったパスワードでログインする") { _, _ in
            LoginPage(app: app).login(
                email: "test@example.com",
                password: "wrongpass"
            )
        }

        Then("表示名 {string} がトップページに表示されている") { matches, _ in
            let name = matches[1]
            TopPage(app: app).verifyDisplayName(name)
        }

        Then("ログアウトボタンが表示されている") { _, _ in
            TopPage(app: app).verifyLogoutButtonExists()
        }

        Then("エラーメッセージ {string} が表示されている") { matches, _ in
            let message = matches[1]
            LoginPage(app: app).verifyError(message)
        }

        // MARK: - Navigation Steps

        Given("トップ画面が表示されている") { _, _ in
            LoginPage(app: app).login(
                email: "test@example.com",
                password: "pass123"
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

        Then("会員 {string} のカードが表示されている") { matches, _ in
            let name = matches[1]
            MemberListPage(app: app).verifyMemberExists(name)
        }

        Given("会員一覧画面が表示されている") { _, _ in
            LoginPage(app: app).login(
                email: "test@example.com",
                password: "pass123"
            )
            TopPage(app: app).tapBorrowingCard()
            MemberListPage(app: app).verifyDisplayed()
        }

        When("^会員 \"(.+)\" のカードをタップする$") { matches, _ in
            let name = matches[1]
            MemberListPage(app: app).tapMember(name)
        }

        // MARK: - Book Catalog Steps

        Then("書籍カタログ画面が表示される") { _, _ in
            BookCatalogPage(app: app).verifyDisplayed()
        }

        Then("選択中メンバー {string} が表示されている") { matches, _ in
            let name = matches[1]
            BookCatalogPage(app: app).verifySelectedMember(name)
        }

        Given("書籍カタログ画面が会員 {string} で表示されている") { matches, _ in
            let memberName = matches[1]
            LoginPage(app: app).login(
                email: "test@example.com",
                password: "pass123"
            )
            TopPage(app: app).tapBorrowingCard()
            MemberListPage(app: app).tapMember(memberName)
            BookCatalogPage(app: app).verifyDisplayed()
        }

        Then("書籍 {string} のカードが表示されている") { matches, _ in
            let title = matches[1]
            BookCatalogPage(app: app).verifyBookExists(title)
        }

        Then("書籍 {string} のカードが表示されていない") { matches, _ in
            let title = matches[1]
            BookCatalogPage(app: app).verifyBookNotExists(title)
        }

        When("{string} フィルタボタンをタップする") { matches, _ in
            let filter = matches[1]
            BookCatalogPage(app: app).tapFilter(filter)
        }

        // MARK: - Borrowing Flow Steps

        Given("^会員 \"(.+)\" の貸出冊数を上限に設定する$") { _, _ in
            app.terminate()
            app.launchArguments.append("--set-borrowing-limit-test")
            app.launch()
        }

        When("^書籍 \"(.+)\" の貸し出しボタンをタップする$") { matches, _ in
            let title = matches[1]
            BookCatalogPage(app: app).tapBorrowButton(forBook: title)
        }

        Then("貸し出し成功メッセージが表示される") { _, _ in
            LoanConfirmationPage(app: app).verifyDisplayed()
        }

        Then("貸し出しエラーメッセージが表示される") { _, _ in
            let alert = app.alerts["エラー"]
            XCTAssertTrue(
                alert.waitForExistence(timeout: 10),
                "貸し出しエラーアラートが表示されていません"
            )
        }
    }
}
