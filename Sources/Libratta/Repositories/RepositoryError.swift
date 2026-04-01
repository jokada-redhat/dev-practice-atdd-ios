import Foundation

public enum RepositoryError: Error, Equatable {
    case notFound
    case duplicateEmail
    case duplicateIsbn
}
