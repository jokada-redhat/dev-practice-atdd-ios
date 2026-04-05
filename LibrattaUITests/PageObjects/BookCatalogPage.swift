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
        // カタログの読み込みを待つ
        verifyDisplayed()

        // 書籍を探す（まず十分に待ち、見つからなければスクロール）
        let bookText = app.staticTexts[title]
        if !bookText.waitForExistence(timeout: 10) {
            for _ in 0..<5 {
                app.swipeUp()
                if bookText.waitForExistence(timeout: 2) { break }
            }
        }
        XCTAssertTrue(bookText.isHittable || bookText.waitForExistence(timeout: 3),
                      "書籍 '\(title)' が見つかりません")

        // 書籍カードの「貸し出す」ボタンをタップ
        let borrowButton = app.buttons.matching(
            NSPredicate(format: "label CONTAINS '貸し出す'")
        ).firstMatch
        XCTAssertTrue(borrowButton.waitForExistence(timeout: 5),
                      "貸し出すボタンが見つかりません")
        borrowButton.tap()
    }

    func confirmBorrowDialog() {
        let sheet = app.sheets.firstMatch
        XCTAssertTrue(sheet.waitForExistence(timeout: 5), "確認ダイアログが表示されていません")
        sheet.buttons["貸し出す"].tap()
    }
}
