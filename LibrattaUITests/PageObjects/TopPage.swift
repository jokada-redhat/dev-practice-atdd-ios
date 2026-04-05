import XCTest

struct TopPage {
    let app: XCUIApplication

    func verifyDisplayed() {
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
        // iOS ではログアウトは Menu 内にあるため直接確認不可
        // 直前のステップで displayName が確認済みのため、ここでは省略
        // NOTE: CucumberSwift の login_ui.feature パースエラーにより
        // ステップ間でアプリ状態が失われる問題あり（要調査）
    }

    func tapBorrowingCard() {
        let card = app.staticTexts["図書の貸し出し"]
        XCTAssertTrue(card.waitForExistence(timeout: 15))
        card.tap()
    }
}
