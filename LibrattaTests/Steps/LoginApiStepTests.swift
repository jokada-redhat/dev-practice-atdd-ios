import XCTest
@testable import Libratta

/// Feature: ログインAPI (login_api.feature)
final class LoginApiStepTests: XCTestCase {

    func testSmoke_正しい認証情報でトークンが返る() async {
        let mockSession = MockURLProtocolSession.create { request in
            let body = try? JSONSerialization.jsonObject(with: request.httpBody ?? Data()) as? [String: Any]
            let email = body?["email"] as? String
            let password = body?["password"] as? String

            if email == "test@example.com" && password == "password123" {
                let responseBody: [String: Any] = [
                    "token": "test-token-abc",
                    "displayName": "テストユーザー"
                ]
                let data = try! JSONSerialization.data(withJSONObject: responseBody)
                let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
                return (data, response)
            }
            let data = try! JSONSerialization.data(withJSONObject: ["error": "Unauthorized"])
            let response = HTTPURLResponse(url: request.url!, statusCode: 401, httpVersion: nil, headerFields: nil)!
            return (data, response)
        }

        let client = AuthApiClient(baseURL: URL(string: "http://localhost:8080")!, session: mockSession)
        let result = await client.login(request: LoginRequest(email: "test@example.com", password: "password123"))

        guard case let .success(token, displayName) = result else {
            XCTFail("ログインが成功するべき")
            return
        }
        XCTAssertEqual(token, "test-token-abc")
        XCTAssertEqual(displayName, "テストユーザー")
    }

    func test誤った認証情報で401が返る() async {
        let mockSession = MockURLProtocolSession.create { _ in
            let data = try! JSONSerialization.data(withJSONObject: ["error": "Unauthorized"])
            let response = HTTPURLResponse(url: URL(string: "http://localhost:8080")!, statusCode: 401, httpVersion: nil, headerFields: nil)!
            return (data, response)
        }

        let client = AuthApiClient(baseURL: URL(string: "http://localhost:8080")!, session: mockSession)
        let result = await client.login(request: LoginRequest(email: "test@example.com", password: "wrongpassword"))

        guard case .failure = result else {
            XCTFail("ログインが失敗するべき")
            return
        }
    }

    func test不正なリクエスト形式で400が返る() async {
        let mockSession = MockURLProtocolSession.create { _ in
            let data = try! JSONSerialization.data(withJSONObject: ["error": "Bad Request"])
            let response = HTTPURLResponse(url: URL(string: "http://localhost:8080")!, statusCode: 400, httpVersion: nil, headerFields: nil)!
            return (data, response)
        }

        let client = AuthApiClient(baseURL: URL(string: "http://localhost:8080")!, session: mockSession)
        let result = await client.login(request: LoginRequest(email: "invalid-email", password: ""))

        guard case .failure = result else {
            XCTFail("ログインが失敗するべき")
            return
        }
    }
}

// MARK: - Mock URLProtocol

private final class MockURLProtocol: URLProtocol, @unchecked Sendable {
    nonisolated(unsafe) static var handler: ((URLRequest) -> (Data, HTTPURLResponse))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = Self.handler else {
            client?.urlProtocolDidFinishLoading(self)
            return
        }
        // URLProtocol may convert httpBody to httpBodyStream
        var mutableRequest = request
        if mutableRequest.httpBody == nil, let stream = mutableRequest.httpBodyStream {
            stream.open()
            var data = Data()
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 1024)
            defer { buffer.deallocate() }
            while stream.hasBytesAvailable {
                let read = stream.read(buffer, maxLength: 1024)
                if read > 0 {
                    data.append(buffer, count: read)
                }
            }
            stream.close()
            mutableRequest.httpBody = data
        }
        let (data, response) = handler(mutableRequest)
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

enum MockURLProtocolSession {
    static func create(handler: @escaping (URLRequest) -> (Data, HTTPURLResponse)) -> URLSession {
        MockURLProtocol.handler = handler
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: config)
    }
}
