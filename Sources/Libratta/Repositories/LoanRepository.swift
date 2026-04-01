import Foundation

public protocol LoanRepository: Sendable {
    func save(_ loan: Loan) throws
    func findById(_ id: String) -> Loan?
    func findByMemberId(_ memberId: String) -> [Loan]
    func findByBookId(_ bookId: String) -> [Loan]
    func findActiveByBookId(_ bookId: String) -> Loan?
    func findAll() -> [Loan]
    func findAllActive() -> [Loan]
    func returnBook(_ loanId: String) throws
    func delete(_ id: String)
    func clear()
}
