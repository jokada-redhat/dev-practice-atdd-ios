import Foundation

public enum BookStatus: String, Sendable {
    case available = "AVAILABLE"
    case borrowed = "BORROWED"
}

public struct Book: Equatable, Identifiable, Sendable {
    public let id: String
    public let title: String
    public let author: String
    public let isbn: String
    public let publicationYear: Int
    public var status: BookStatus

    public var isAvailable: Bool {
        status == .available
    }

    public init(
        id: String = UUID().uuidString,
        title: String,
        author: String,
        isbn: String,
        publicationYear: Int,
        status: BookStatus = .available
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.isbn = isbn
        self.publicationYear = publicationYear
        self.status = status
    }
}
