import XCTest
@testable import Libratta

/// Feature: ログイン機能 (login.feature)
final class LoginStepTests: XCTestCase {
    private var stubAuth: StubAuthRepository!
    private var loginUseCase: LoginUseCase!

    override func setUp() {
        stubAuth = StubAuthRepository()
        loginUseCase = LoginUseCase(authRepository: stubAuth)
    }

    func test正しい認証情報でログインできる() async {
        stubAuth.registerUser(email: "test@example.com", password: "password123", displayName: "テストユーザー")

        let result = await loginUseCase.execute(request: LoginRequest(email: "test@example.com", password: "password123"))

        guard case let .success(token, displayName) = result else {
            XCTFail("ログインが成功するべき")
            return
        }
        XCTAssertFalse(token.isEmpty)
        XCTAssertEqual(displayName, "テストユーザー")
    }

    func test誤ったパスワードではログインできない() async {
        stubAuth.registerUser(email: "test@example.com", password: "password123", displayName: "テストユーザー")

        let result = await loginUseCase.execute(request: LoginRequest(email: "test@example.com", password: "wrongpassword"))

        guard case let .failure(message) = result else {
            XCTFail("ログインが失敗するべき")
            return
        }
        XCTAssertEqual(message, "メールアドレスまたはパスワードが正しくありません")
    }

    func test未登録のメールアドレスではログインできない() async {
        let result = await loginUseCase.execute(request: LoginRequest(email: "unknown@example.com", password: "password123"))

        guard case let .failure(message) = result else {
            XCTFail("ログインが失敗するべき")
            return
        }
        XCTAssertEqual(message, "メールアドレスまたはパスワードが正しくありません")
    }

    func testメールアドレスが空ではログインできない() async {
        let result = await loginUseCase.execute(request: LoginRequest(email: "", password: "password123"))

        guard case let .validationError(message) = result else {
            XCTFail("バリデーションエラーが発生するべき")
            return
        }
        XCTAssertEqual(message, "メールアドレスを入力してください")
    }

    func testパスワードが空ではログインできない() async {
        let result = await loginUseCase.execute(request: LoginRequest(email: "test@example.com", password: ""))

        guard case let .validationError(message) = result else {
            XCTFail("バリデーションエラーが発生するべき")
            return
        }
        XCTAssertEqual(message, "パスワードを入力してください")
    }
}
