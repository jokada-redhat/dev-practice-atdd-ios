import SwiftUI

enum LoginUiState: Equatable {
    case idle
    case loading
    case success(displayName: String)
    case error(message: String)
}

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var uiState: LoginUiState = .idle

    let isDebugMode: Bool

    private let loginUseCase: LoginUseCase
    private let sessionManager: SessionManager

    init(loginUseCase: LoginUseCase, sessionManager: SessionManager, isDebugMode: Bool = false) {
        self.loginUseCase = loginUseCase
        self.sessionManager = sessionManager
        self.isDebugMode = isDebugMode

        if isDebugMode {
            self.email = "librarian@example.com"
            self.password = "password"
        }
    }

    func login() async {
        uiState = .loading

        let result = await loginUseCase.execute(
            request: LoginRequest(email: email, password: password)
        )

        switch result {
        case let .success(token, displayName):
            sessionManager.saveSession(token: token, displayName: displayName)
            uiState = .success(displayName: displayName)
        case let .failure(message):
            uiState = .error(message: message)
        case let .validationError(message):
            uiState = .error(message: message)
        }
    }
}
