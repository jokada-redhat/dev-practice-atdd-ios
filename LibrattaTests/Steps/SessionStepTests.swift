import XCTest
@testable import Libratta

/// Feature: セッション管理機能 (session.feature)
final class SessionStepTests: XCTestCase {

    func testログイン成功時にセッションが保存される() {
        let sessionManager = SessionManager(repository: InMemorySessionRepository())

        XCTAssertFalse(sessionManager.isLoggedIn)

        sessionManager.saveSession(token: "test-token-123", displayName: "テストユーザー")

        XCTAssertTrue(sessionManager.isLoggedIn)
        XCTAssertEqual(sessionManager.displayName, "テストユーザー")
    }

    func testセッションが存在する場合はログイン状態と判定される() {
        let sessionManager = SessionManager(repository: InMemorySessionRepository())
        sessionManager.saveSession(token: "saved-token", displayName: "既存ユーザー")

        XCTAssertTrue(sessionManager.isLoggedIn)
    }

    func testセッションが存在しない場合は未ログイン状態と判定される() {
        let sessionManager = SessionManager(repository: InMemorySessionRepository())

        XCTAssertFalse(sessionManager.isLoggedIn)
    }

    func testログアウト時にセッションがクリアされる() {
        let sessionManager = SessionManager(repository: InMemorySessionRepository())
        sessionManager.saveSession(token: "test-token", displayName: "テストユーザー")

        sessionManager.clearSession()

        XCTAssertFalse(sessionManager.isLoggedIn)
    }
}
