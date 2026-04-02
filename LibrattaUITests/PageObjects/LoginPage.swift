import XCTest

struct LoginPage {
    let app: XCUIApplication

    var emailField: XCUIElement { app.textFields["emailField"] }
    var passwordField: XCUIElement { app.secureTextFields["passwordField"] }
    var loginButton: XCUIElement { app.buttons["loginButton"] }

    func login(email: String, password: String) {
        XCTAssertTrue(emailField.waitForExistence(timeout: 10))

        // デバッグモードで prefill されている場合はクリアしてから入力
        emailField.tap()
        if let currentValue = emailField.value as? String, !currentValue.isEmpty {
            emailField.press(forDuration: 1.0)
            if app.menuItems["Select All"].waitForExistence(timeout: 2) {
                app.menuItems["Select All"].tap()
            }
        }
        emailField.typeText(email)

        passwordField.tap()
        if let currentValue = passwordField.value as? String,
           !currentValue.isEmpty, currentValue != "パスワード" {
            passwordField.press(forDuration: 1.0)
            if app.menuItems["Select All"].waitForExistence(timeout: 2) {
                app.menuItems["Select All"].tap()
            }
        }
        passwordField.typeText(password)

        loginButton.tap()
    }

    func verifyError(_ message: String) {
        XCTAssertTrue(
            app.staticTexts[message].waitForExistence(timeout: 10),
            "エラーメッセージ '\(message)' が表示されていません"
        )
    }
}
