import XCTest

struct TopPage {
    let app: XCUIApplication

    func verifyDisplayed() {
        XCTAssertTrue(
            app.navigationBars["Libratta"].waitForExistence(timeout: 10),
            "トップ画面が表示されていません"
        )
    }

    func verifyDisplayName(_ name: String) {
        let element = app.staticTexts["displayName"]
        XCTAssertTrue(
            element.waitForExistence(timeout: 10),
            "表示名が見つかりません"
        )
        XCTAssertEqual(element.label, name)
    }

    func verifyLogoutButtonExists() {
        // ログアウトはツールバーメニュー内にあるので、メニューボタンの存在を確認
        XCTAssertTrue(
            app.buttons["ellipsis.circle"].waitForExistence(timeout: 10),
            "メニューボタンが表示されていません"
        )
    }

    func tapBorrowingCard() {
        let card = app.staticTexts["図書の貸し出し"]
        XCTAssertTrue(card.waitForExistence(timeout: 10))
        card.tap()
    }
}
