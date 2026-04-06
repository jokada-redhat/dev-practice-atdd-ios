import XCTest
import CucumberSwift

extension Cucumber: StepImplementation {
    public var bundle: Bundle {
        class Findme { }
        return Bundle(for: Findme.self)
    }

    // swiftlint:disable:next function_body_length
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

        Then("ログアウトボタンが表示されている") { _, _ in
            TopPage(app: app).verifyLogoutButtonExists()
        }

        Then("エラーメッセージ {string} が表示されている") { matches, _ in
            let message = matches[1]
            LoginPage(app: app).verifyError(message)
        }

        // MARK: - Navigation Steps

        Given("トップ画面が表示されている") { _, _ in
            // 既にトップ画面にいる場合はスキップ
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

        Given("^会員 \"(.+)\" の貸出冊数を上限に設定する$") { matches, _ in
            let memberName = matches[1]
            // DA-0001 は既に2冊借りている（上限3冊）ので、UI で1冊借りて上限到達
            LoginPage(app: app).login(
                email: "librarian@example.com",
                password: "password"
            )
            TopPage(app: app).tapBorrowingCard()
            MemberListPage(app: app).tapMember(memberName)
            BookCatalogPage(app: app).tapBorrowButton(forBook: "坊っちゃん")
            BookCatalogPage(app: app).confirmBorrowDialog()
            LoanConfirmationPage(app: app).verifyDisplayed()
            // ホームに戻る
            let homeButton = app.buttons["ホームに戻る"]
            XCTAssertTrue(homeButton.waitForExistence(timeout: 10))
            homeButton.tap()
            // トップ画面に戻ったことを確認（次の And トップ画面 ではログイン済みをスキップ）
            TopPage(app: app).verifyDisplayed()
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
            let alert = app.alerts.firstMatch
            XCTAssertTrue(
                alert.waitForExistence(timeout: 10),
                "貸し出しエラーアラートが表示されていません"
            )
        }
    }
}
