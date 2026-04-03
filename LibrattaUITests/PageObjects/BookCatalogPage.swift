import XCTest

struct BookCatalogPage {
    let app: XCUIApplication

    func verifyDisplayed() {
        XCTAssertTrue(
            app.navigationBars["書籍カタログ"].waitForExistence(timeout: 15),
            "書籍カタログ画面が表示されていません"
        )
    }

    func verifySelectedMember(_ name: String) {
        let member = app.staticTexts["selectedMember"]
        XCTAssertTrue(member.waitForExistence(timeout: 10))
        XCTAssertEqual(member.label, name)
    }

    func verifyBookExists(_ title: String) {
        XCTAssertTrue(
            app.staticTexts[title].waitForExistence(timeout: 10),
            "書籍 '\(title)' が表示されていません"
        )
    }

    func verifyBookNotExists(_ title: String) {
        XCTAssertFalse(
            app.staticTexts[title].waitForExistence(timeout: 2),
            "書籍 '\(title)' が表示されています（非表示であるべき）"
        )
    }

    func tapFilter(_ filterName: String) {
        let filter = app.buttons[filterName]
        XCTAssertTrue(filter.waitForExistence(timeout: 10))
        filter.tap()
    }

    func tapBorrowButton(forBook title: String) {
        // 書籍を探す（スクロール）
        let bookText = app.staticTexts[title]
        if !bookText.waitForExistence(timeout: 5) {
            app.swipeUp()
            XCTAssertTrue(bookText.waitForExistence(timeout: 5))
        }

        // 「貸し出す」ボタンをタップ
        let borrowButton = app.buttons.matching(
            NSPredicate(format: "label CONTAINS '貸し出す'")
        ).firstMatch
        if !borrowButton.waitForExistence(timeout: 5) {
            app.swipeUp()
        }
        XCTAssertTrue(borrowButton.waitForExistence(timeout: 5))
        borrowButton.tap()

        // 確認ダイアログ (ActionSheet) で「貸し出す」をタップ
        let sheet = app.sheets.firstMatch
        if sheet.waitForExistence(timeout: 5) {
            sheet.buttons["貸し出す"].tap()
        }
    }
}
