import Foundation

public protocol LoanRepository: Sendable {
    func save(_ loan: Loan) throws
    func findById(_ id: String) -> Loan?
    func findByMemberId(_ memberId: String) -> [Loan]
    func findByBookId(_ bookId: String) -> Loan?
    func findActiveByBookId(_ bookId: String) -> Loan?
    func findAll() -> [Loan]
    func countActiveByMemberId(_ memberId: String) -> Int
    func findBorrowedBookIds() -> Set<String>
    func delete(_ id: String)
    func clear()
}
