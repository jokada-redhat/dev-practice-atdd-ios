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

        Given("会員 {string} の貸出冊数を上限に設定する" as CucumberExpression) { matches, _ in
            let memberName = try matches.first(\.string)
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
            // トップ画面に戻ったことを確認
            TopPage(app: app).verifyDisplayed()
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
