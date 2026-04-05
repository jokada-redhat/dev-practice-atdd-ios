import XCTest

struct MemberListPage {
    let app: XCUIApplication

    func verifyDisplayed() {
        XCTAssertTrue(
            app.navigationBars["会員一覧"].waitForExistence(timeout: 10),
            "会員一覧画面が表示されていません"
        )
    }

    func verifyMemberExists(_ name: String) {
        let element = app.staticTexts[name]
        if !element.waitForExistence(timeout: 3) {
            for _ in 0..<5 {
                app.swipeUp()
                if element.waitForExistence(timeout: 2) { break }
            }
        }
        XCTAssertTrue(
            element.waitForExistence(timeout: 5),
            "会員 '\(name)' が表示されていません"
        )
    }

    func tapMember(_ name: String) {
        let element = app.staticTexts[name]
        if !element.waitForExistence(timeout: 5) {
            for _ in 0..<5 {
                app.swipeUp()
                if element.waitForExistence(timeout: 2) { break }
            }
        }
        XCTAssertTrue(element.waitForExistence(timeout: 5),
                      "会員 '\(name)' が見つかりません")
        element.tap()

        // 書籍カタログ画面への遷移を待つ
        _ = app.navigationBars["書籍カタログ"].waitForExistence(timeout: 15)
    }
}
