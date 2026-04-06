import XCTest
import CucumberSwift
import CucumberSwiftExpressions

extension Cucumber {
    func registerLoginUISteps(app: XCUIApplication) {
        Given("未ログイン状態になっている") { _, _ in
        }

        When("以下の認証情報でログインする") { _, step in
            let row = step.dataTable!.rows[1]
            LoginPage(app: app).login(email: row[0], password: row[1])
        }

        Then("表示名 {string} がトップページに表示されている" as CucumberExpression) { matches, _ in
            let name = try matches.first(\.string)
            TopPage(app: app).verifyDisplayName(name)
        }

        Then("ログアウトボタンが表示されている") { _, _ in
            TopPage(app: app).verifyLogoutButtonExists()
        }

        Then("エラーメッセージ {string} が表示されている" as CucumberExpression) { matches, _ in
            let message = try matches.first(\.string)
            LoginPage(app: app).verifyError(message)
        }
    }
}
