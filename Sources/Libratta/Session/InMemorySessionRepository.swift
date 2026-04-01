import Foundation

public final class InMemorySessionRepository: SessionRepository, @unchecked Sendable {
    private var token: String?
    private var displayName: String?

    public init() {}

    public func saveToken(_ token: String) {
        self.token = token
    }

    public func getToken() -> String? {
        token
    }

    public func saveDisplayName(_ displayName: String) {
        self.displayName = displayName
    }

    public func getDisplayName() -> String? {
        displayName
    }

    public func clear() {
        token = nil
        displayName = nil
    }
}
