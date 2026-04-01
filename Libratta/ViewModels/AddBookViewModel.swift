import SwiftUI

@MainActor
final class AddBookViewModel: ObservableObject {
    @Published var title = ""
    @Published var author = ""
    @Published var isbn = ""
    @Published var publicationYear = ""
    @Published var errorMessage: String?
    @Published var isSuccess = false

    private let registerBookUseCase: RegisterBookUseCase

    init(registerBookUseCase: RegisterBookUseCase) {
        self.registerBookUseCase = registerBookUseCase
    }

    func register() {
        let year = Int(publicationYear) ?? 0
        let result = registerBookUseCase.execute(
            title: title,
            author: author,
            isbn: isbn,
            publicationYear: year
        )
        switch result {
        case .success:
            isSuccess = true
            errorMessage = nil
        case let .validationError(message), let .error(message):
            errorMessage = message
        }
    }
}
