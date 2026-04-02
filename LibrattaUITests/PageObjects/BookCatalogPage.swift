import XCTest

struct BookCatalogPage {
    let app: XCUIApplication

    func verifyDisplayed() {
        XCTAssertTrue(
            app.navigationBars["書籍カタログ"].waitForExistence(timeout: 5),
            "書籍カタログ画面が表示されていません"
        )
    }

    func verifySelectedMember(_ name: String) {
        let member = app.staticTexts["selectedMember"]
        XCTAssertTrue(member.waitForExistence(timeout: 5))
        XCTAssertEqual(member.label, name)
    }

    func verifyBookExists(_ title: String) {
        XCTAssertTrue(
            app.staticTexts[title].waitForExistence(timeout: 5),
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
        XCTAssertTrue(filter.waitForExistence(timeout: 5))
        filter.tap()
    }

    func tapBorrowButton(forBook title: String) {
        let scrollView = app.scrollViews.firstMatch
        scrollView.swipeUp()

        let bookTexts = app.staticTexts.matching(
            NSPredicate(format: "label == %@", title)
        )
        XCTAssertTrue(bookTexts.firstMatch.waitForExistence(timeout: 5))

        let borrowButtons = app.buttons.matching(
            NSPredicate(format: "label CONTAINS '貸し出す'")
        )
        XCTAssertTrue(borrowButtons.firstMatch.waitForExistence(timeout: 5))
        borrowButtons.firstMatch.tap()

        // 確認ダイアログで「貸し出す」をタップ
        let confirmButton = app.buttons["貸し出す"]
        if confirmButton.waitForExistence(timeout: 3) {
            confirmButton.tap()
        }
    }
}
