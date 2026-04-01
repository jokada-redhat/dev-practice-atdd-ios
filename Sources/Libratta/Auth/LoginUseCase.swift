import Foundation

public final class LoginUseCase: Sendable {
    private let authRepository: AuthRepository

    public init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    public func execute(request: LoginRequest) async -> LoginResult {
        if request.email.isEmpty {
            return .validationError(message: "メールアドレスを入力してください")
        }
        if request.password.isEmpty {
            return .validationError(message: "パスワードを入力してください")
        }
        return await authRepository.login(request: request)
    }
}
