import SwiftUI

@MainActor
final class AddMemberViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var errorMessage: String?
    @Published var isSuccess = false

    private let registerMemberUseCase: RegisterMemberUseCase

    init(registerMemberUseCase: RegisterMemberUseCase) {
        self.registerMemberUseCase = registerMemberUseCase
    }

    func register() {
        let result = registerMemberUseCase.execute(name: name, email: email)
        switch result {
        case .success:
            isSuccess = true
            errorMessage = nil
        case let .validationError(message), let .error(message):
            errorMessage = message
        }
    }
}
