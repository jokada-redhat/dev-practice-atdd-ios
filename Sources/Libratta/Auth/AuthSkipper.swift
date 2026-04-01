import Foundation

public struct AuthSkipper: Sendable {
    public let isEnabled: Bool

    public init(isEnabled: Bool) {
        self.isEnabled = isEnabled
    }

    public func checkAndSetSession(sessionManager: SessionManager) {
        guard isEnabled else { return }
        if !sessionManager.isLoggedIn {
            sessionManager.saveSession(token: "debug-token", displayName: "開発ユーザー")
        }
    }
}
