import Foundation

public enum RegisterBookResult: Equatable {
    case success(Book)
    case validationError(message: String)
    case error(message: String)
}

public final class RegisterBookUseCase: Sendable {
    private let bookRepository: BookRepository

    public init(bookRepository: BookRepository) {
        self.bookRepository = bookRepository
    }

    public func execute(title: String, author: String, isbn: String, publicationYear: Int) -> RegisterBookResult {
        if title.trimmingCharacters(in: .whitespaces).isEmpty {
            return .validationError(message: "タイトルを入力してください")
        }

        let book = Book(
            title: title,
            author: author,
            isbn: isbn,
            publicationYear: publicationYear
        )

        do {
            try bookRepository.save(book)
            return .success(book)
        } catch RepositoryError.duplicateIsbn {
            return .error(message: "このISBNは既に登録されています")
        } catch {
            return .error(message: "登録に失敗しました")
        }
    }
}
