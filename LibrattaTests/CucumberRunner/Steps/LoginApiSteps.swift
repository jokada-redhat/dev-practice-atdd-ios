import XCTest
import CucumberSwift
import CucumberSwiftExpressions
@testable import Libratta

extension Cucumber {
    // swiftlint:disable:next function_body_length
    func registerLoginApiSteps(context: ScenarioContext) {
        Given("ログインAPIサーバーが起動している") { _, _ in }

        When("POST {string} に以下のJSONを送信する:" as CucumberExpression) { matches, step in
            _ = try matches.first(\.string)
            guard let rows = step.dataTable?.rows else { return }

            var jsonBody: [String: String] = [:]
            for row in rows {
                guard row.count >= 2 else { continue }
                jsonBody[row[0]] = row[1]
            }

            nonisolated(unsafe) var mockStatusCode = 0
            nonisolated(unsafe) var mockResponseBody: [String: Any] = [:]

            let mockSession = MockURLProtocolSession.create { request in
                let body = try? JSONSerialization.jsonObject(with: request.httpBody ?? Data()) as? [String: Any]
                let email = body?["email"] as? String
                let password = body?["password"] as? String

                if email == nil || password == nil
                    || (password?.isEmpty ?? true) || !(email?.contains("@") ?? false) {
                    mockStatusCode = 400
                    mockResponseBody = ["error": "Bad Request"]
                    // swiftlint:disable:next force_try
                    let data = try! JSONSerialization.data(withJSONObject: mockResponseBody)
                    let response = HTTPURLResponse(
                        url: request.url!, statusCode: 400, httpVersion: nil, headerFields: nil
                    )!
                    return (data, response)
                }

                if email == "test@example.com" && password == "password123" {
                    mockStatusCode = 200
                    mockResponseBody = ["token": "test-token-abc", "displayName": "テストユーザー"]
                    // swiftlint:disable:next force_try
                    let data = try! JSONSerialization.data(withJSONObject: mockResponseBody)
                    let response = HTTPURLResponse(
                        url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil
                    )!
                    return (data, response)
                }

                mockStatusCode = 401
                mockResponseBody = ["error": "Unauthorized"]
                // swiftlint:disable:next force_try
                let data = try! JSONSerialization.data(withJSONObject: mockResponseBody)
                let response = HTTPURLResponse(
                    url: request.url!, statusCode: 401, httpVersion: nil, headerFields: nil
                )!
                return (data, response)
            }

            let client = AuthApiClient(baseURL: URL(string: "http://localhost:8080")!, session: mockSession)
            let request = LoginRequest(
                email: jsonBody["email"] ?? "",
                password: jsonBody["password"] ?? ""
            )

            let semaphore = DispatchSemaphore(value: 0)
            nonisolated(unsafe) var loginResult: LoginResult!
            Task { @Sendable in
                loginResult = await client.login(request: request)
                semaphore.signal()
            }
            semaphore.wait()
            context.loginResult = loginResult
            context.apiStatusCode = mockStatusCode
            context.apiResponseBody = mockResponseBody
        }

        Then("レスポンスステータスが {int} である" as CucumberExpression) { matches, _ in
            let expected = try matches.first(\.int)
            XCTAssertEqual(context.apiStatusCode, expected)
        }

        Then("レスポンスに {string} フィールドが含まれる" as CucumberExpression) { matches, _ in
            let field = try matches.first(\.string)
            XCTAssertNotNil(context.apiResponseBody?[field])
        }
    }
}
