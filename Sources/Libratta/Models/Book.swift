import Foundation

public struct Book: Equatable, Identifiable, Sendable {
    public let id: String
    public let title: String
    public let author: String
    public let isbn: String
    public let publicationYear: Int

    public init(
        id: String = UUID().uuidString,
        title: String,
        author: String,
        isbn: String,
        publicationYear: Int
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.isbn = isbn
        self.publicationYear = publicationYear
    }
}
