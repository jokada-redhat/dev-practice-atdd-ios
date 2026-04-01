import Foundation

public final class StubAuthRepository: AuthRepository, @unchecked Sendable {
    private var registeredUsers: [(email: String, password: String, displayName: String)] = []

    public init() {}

    public func registerUser(email: String, password: String, displayName: String) {
        registeredUsers.append((email: email, password: password, displayName: displayName))
    }

    public func login(request: LoginRequest) async -> LoginResult {
        guard let user = registeredUsers.first(where: { $0.email == request.email }) else {
            return .failure(message: "メールアドレスまたはパスワードが正しくありません")
        }
        if user.password != request.password {
            return .failure(message: "メールアドレスまたはパスワードが正しくありません")
        }
        return .success(token: "stub-token-\(UUID().uuidString)", displayName: user.displayName)
    }
}
