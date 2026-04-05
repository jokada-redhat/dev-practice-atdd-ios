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

        When("メールアドレス {string} とパスワード {string} でログインする") { matches, _ in
            let email = matches[1]
            let password = matches[2]
            LoginPage(app: app).login(email: email, password: password)
        }

        Then("表示名 {string} がトップページに表示されている") { matches, _ in
            let name = matches[1]
            TopPage(app: app).verifyDisplayName(name)
        }

        // NOTE: And ステップは CucumberSwift の制約 (issue #32) により
        // Then/When で定義すれば実行時に And からも解決される。
        // testGherkin バリデータのみ未解決エラーを報告するが、実行には影響なし。
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

        Then("会員 {string} のカードが表示されている") { matches, _ in
            let name = matches[1]
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
                email: "librarian@example.com",
                password: "password"
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

        When("貸し出し確認ダイアログで「貸し出す」をタップする") { _, _ in
            BookCatalogPage(app: app).confirmBorrowDialog()
        }

        Then("貸し出し確認画面が表示される") { _, _ in
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
