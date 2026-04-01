import Foundation

public enum RepositoryError: Error, Equatable {
    case notFound
    case duplicateIsbn
}
