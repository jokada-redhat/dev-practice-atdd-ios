import XCTest
import CucumberSwift
import CucumberSwiftExpressions
@testable import Libratta

extension Cucumber {
    // swiftlint:disable:next function_body_length
    func registerLoginSteps(context: ScenarioContext) {
        Given("ログインAPIが利用可能である") { _, _ in
            context.stubAuth = StubAuthRepository()
            context.loginUseCase = LoginUseCase(authRepository: context.stubAuth)
        }

        Given("以下の認証情報でユーザーが登録されている:") { _, step in
            guard let rows = step.dataTable?.rows, rows.count >= 2 else { return }
            let row = rows[1]
            context.stubAuth.registerUser(email: row[0], password: row[1], displayName: "テストユーザー")
        }

        When("以下の認証情報でログインする") { _, step in
            guard let rows = step.dataTable?.rows, rows.count >= 2 else { return }
            let row = rows[1]
            let email = row[0]
            let password = row[1]
            if context.loginUseCase == nil {
                context.loginUseCase = LoginUseCase(authRepository: context.stubAuth)
            }
            let semaphore = DispatchSemaphore(value: 0)
            nonisolated(unsafe) var result: LoginResult!
            Task { @Sendable in
                result = await context.loginUseCase.execute(
                    request: LoginRequest(email: email, password: password)
                )
                semaphore.signal()
            }
            semaphore.wait()
            context.loginResult = result
        }

        Then("ログインが成功する") { _, _ in
            guard case .success = context.loginResult else {
                XCTFail("ログインが成功するべき"); return
            }
        }

        Then("ログインが失敗する") { _, _ in
            guard case .failure = context.loginResult else {
                XCTFail("ログインが失敗するべき"); return
            }
        }

        Then("アクセストークンが返される") { _, _ in
            guard case let .success(token, _) = context.loginResult else {
                XCTFail("ログインが成功するべき"); return
            }
            XCTAssertFalse(token.isEmpty)
        }

        Then("表示名 {string} が返される" as CucumberExpression) { matches, _ in
            let expected = try matches.first(\.string)
            guard case let .success(_, displayName) = context.loginResult else {
                XCTFail("ログインが成功するべき"); return
            }
            XCTAssertEqual(displayName, expected)
        }

        Then("バリデーションエラー {string} が発生する" as CucumberExpression) { matches, _ in
            let expected = try matches.first(\.string)
            guard case let .validationError(message) = context.loginResult else {
                XCTFail("バリデーションエラーが発生するべき"); return
            }
            XCTAssertEqual(message, expected)
        }
    }
}
