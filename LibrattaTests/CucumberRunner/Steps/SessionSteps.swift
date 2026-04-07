import XCTest
import CucumberSwift
import CucumberSwiftExpressions
@testable import Libratta

extension Cucumber {
    func registerSessionSteps(context: ScenarioContext) {
        Given("セッションが空である") { _, _ in
            context.sessionManager = SessionManager(repository: context.sessionRepo)
        }

        Given("トークン {string} と表示名 {string} でセッションが保存されている" as CucumberExpression) { matches, _ in
            let token = try matches.first(\.string)
            let displayName = try matches.last(\.string)
            context.sessionManager = SessionManager(repository: context.sessionRepo)
            context.sessionManager.saveSession(token: token, displayName: displayName)
        }

        When("トークン {string} と表示名 {string} でセッションを保存する" as CucumberExpression) { matches, _ in
            let token = try matches.first(\.string)
            let displayName = try matches.last(\.string)
            context.sessionManager.saveSession(token: token, displayName: displayName)
        }

        When("セッションをクリアする") { _, _ in
            context.sessionManager.clearSession()
        }

        Then("ログイン済みと判定される") { _, _ in
            XCTAssertTrue(context.sessionManager.isLoggedIn)
        }

        Then("未ログインと判定される") { _, _ in
            XCTAssertFalse(context.sessionManager.isLoggedIn)
        }

        Then("保存されたトークンは {string} である" as CucumberExpression) { _, _ in
            XCTAssertTrue(context.sessionManager.isLoggedIn)
        }

        Then("保存された表示名は {string} である" as CucumberExpression) { matches, _ in
            let expected = try matches.first(\.string)
            XCTAssertEqual(context.sessionManager.displayName, expected)
        }
    }
}
