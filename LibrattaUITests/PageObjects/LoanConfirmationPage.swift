import XCTest

struct LoanConfirmationPage {
    let app: XCUIApplication

    func verifyDisplayed() {
        XCTAssertTrue(
            app.staticTexts["貸し出しが完了しました"].waitForExistence(timeout: 10),
            "貸し出し完了画面が表示されていません"
        )
    }
}
