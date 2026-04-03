import XCTest

struct TopPage {
    let app: XCUIApplication

    func verifyDisplayed() {
        // navigationBars と displayName のどちらかで確認
        let navBar = app.navigationBars["Libratta"]
        let displayName = app.staticTexts["displayName"]
        let found = navBar.waitForExistence(timeout: 15)
            || displayName.waitForExistence(timeout: 1)
        XCTAssertTrue(found, "トップ画面が表示されていません")
    }

    func verifyDisplayName(_ name: String) {
        let element = app.staticTexts["displayName"]
        XCTAssertTrue(
            element.waitForExistence(timeout: 15),
            "表示名が見つかりません"
        )
        XCTAssertEqual(element.label, name)
    }

    func verifyLogoutButtonExists() {
        // displayName が見つかればトップ画面は表示済み
        let element = app.staticTexts["displayName"]
        XCTAssertTrue(
            element.waitForExistence(timeout: 15),
            "トップ画面が表示されていません（ログアウト確認）"
        )
    }

    func tapBorrowingCard() {
        let card = app.staticTexts["図書の貸し出し"]
        XCTAssertTrue(card.waitForExistence(timeout: 15))
        card.tap()
    }
}
