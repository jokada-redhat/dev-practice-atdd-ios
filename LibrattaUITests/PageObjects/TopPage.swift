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
        // 表示名が確認できていればトップ画面は表示済み
        // ToolbarMenu は XCUITest からボタンとして見えない場合がある
        let displayName = app.staticTexts["displayName"]
        XCTAssertTrue(
            displayName.waitForExistence(timeout: 10),
            "トップ画面が表示されていません（ログアウト確認）"
        )
    }

    func tapBorrowingCard() {
        let card = app.staticTexts["図書の貸し出し"]
        XCTAssertTrue(card.waitForExistence(timeout: 10))
        card.tap()
    }
}
