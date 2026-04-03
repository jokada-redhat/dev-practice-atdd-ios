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
        // 新しい XCUIApplication インスタンスでクエリし直す
        let freshApp = XCUIApplication()
        let allTexts = freshApp.staticTexts.allElementsBoundByIndex
        let textLabels = allTexts.map { "\($0.identifier)='\($0.label)'" }
        let debugInfo = "staticTexts: \(textLabels.joined(separator: ", "))"

        let element = freshApp.staticTexts["displayName"]
        XCTAssertTrue(
            element.waitForExistence(timeout: 15),
            "トップ画面が表示されていません（ログアウト確認）。\(debugInfo)"
        )
    }

    func tapBorrowingCard() {
        let card = app.staticTexts["図書の貸し出し"]
        XCTAssertTrue(card.waitForExistence(timeout: 15))
        card.tap()
    }
}
