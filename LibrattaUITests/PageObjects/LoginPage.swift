import XCTest

struct LoginPage {
    let app: XCUIApplication

    var emailField: XCUIElement { app.textFields["emailField"] }
    var passwordField: XCUIElement { app.secureTextFields["passwordField"] }
    var loginButton: XCUIElement { app.buttons["loginButton"] }

    func login(email: String, password: String) {
        XCTAssertTrue(emailField.waitForExistence(timeout: 10))

        let currentEmail = emailField.value as? String ?? ""
        if currentEmail == email {
            // prefill が一致 → そのままログイン
            loginButton.tap()
        } else {
            // 値が違う場合はクリアして入力
            clearAndType(field: emailField, text: email)
            clearAndType(field: passwordField, text: password)
            loginButton.tap()
        }

        // ログイン完了（TopView 表示 or エラー表示）を待つ
        let displayName = app.staticTexts["displayName"]
        let errorMessage = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS 'パスワード'")
        ).firstMatch
        _ = displayName.waitForExistence(timeout: 15)
            || errorMessage.waitForExistence(timeout: 1)
    }

    func verifyError(_ message: String) {
        XCTAssertTrue(
            app.staticTexts[message].waitForExistence(timeout: 10),
            "エラーメッセージ '\(message)' が表示されていません"
        )
    }

    private func clearAndType(field: XCUIElement, text: String) {
        field.tap()
        field.tap(withNumberOfTaps: 3, numberOfTouches: 1)
        field.typeText(text)
    }
}
