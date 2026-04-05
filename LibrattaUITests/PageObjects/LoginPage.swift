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
            // メールアドレスはプリフィルと一致
            // パスワードも変更不要なら、そのままログイン
            let currentPwdLen = (passwordField.value as? String)?.count ?? 0
            if currentPwdLen != password.count {
                // パスワード長が異なる → 誤パスワードテスト等
                selectAllAndType(field: passwordField, text: password)
            }
            loginButton.tap()
        } else {
            // メールアドレスが異なる → 両方入力
            selectAllAndType(field: emailField, text: email)
            selectAllAndType(field: passwordField, text: password)
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

    private func selectAllAndType(field: XCUIElement, text: String) {
        field.tap()
        field.tap(withNumberOfTaps: 3, numberOfTouches: 1)
        Thread.sleep(forTimeInterval: 0.3)
        field.typeText(text)
    }
}
