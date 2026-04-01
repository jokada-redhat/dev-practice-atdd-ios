import Foundation

public protocol AuthRepository: Sendable {
    func login(request: LoginRequest) async -> LoginResult
}
