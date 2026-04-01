import Foundation

public struct Loan: Equatable, Identifiable, Sendable {
    public let id: String
    public let memberId: String
    public let bookId: String
    public let borrowedDate: Date
    public var returnedDate: Date?

    public var isReturned: Bool {
        returnedDate != nil
    }

    public init(
        id: String = UUID().uuidString,
        memberId: String,
        bookId: String,
        borrowedDate: Date = Date(),
        returnedDate: Date? = nil
    ) {
        self.id = id
        self.memberId = memberId
        self.bookId = bookId
        self.borrowedDate = borrowedDate
        self.returnedDate = returnedDate
    }
}
