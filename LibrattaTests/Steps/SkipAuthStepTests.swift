import XCTest
@testable import Libratta

/// Feature: 開発用認証スキップ機能 (skip_auth.feature)
final class SkipAuthStepTests: XCTestCase {

    func test認証スキップが有効な場合_未ログインでもダミーセッションが保存される() {
        let sessionManager = SessionManager(repository: InMemorySessionRepository())
        let skipper = AuthSkipper(isEnabled: true)

        XCTAssertFalse(sessionManager.isLoggedIn)

        skipper.checkAndSetSession(sessionManager: sessionManager)

        XCTAssertTrue(sessionManager.isLoggedIn)
        XCTAssertEqual(sessionManager.displayName, "開発ユーザー")
    }

    func test認証スキップが無効な場合_未ログイン状態が維持される() {
        let sessionManager = SessionManager(repository: InMemorySessionRepository())
        let skipper = AuthSkipper(isEnabled: false)

        XCTAssertFalse(sessionManager.isLoggedIn)

        skipper.checkAndSetSession(sessionManager: sessionManager)

        XCTAssertFalse(sessionManager.isLoggedIn)
    }
}
