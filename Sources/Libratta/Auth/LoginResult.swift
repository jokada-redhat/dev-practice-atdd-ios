import Foundation

public enum LoginResult: Equatable, Sendable {
    case success(token: String, displayName: String)
    case failure(message: String)
    case validationError(message: String)
}
