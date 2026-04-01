import Foundation

public final class SessionManager: @unchecked Sendable {
    private let repository: SessionRepository

    public init(repository: SessionRepository) {
        self.repository = repository
    }

    public var isLoggedIn: Bool {
        repository.getToken() != nil
    }

    public var displayName: String? {
        repository.getDisplayName()
    }

    public func saveSession(token: String, displayName: String) {
        repository.saveToken(token)
        repository.saveDisplayName(displayName)
    }

    public func clearSession() {
        repository.clear()
    }
}
