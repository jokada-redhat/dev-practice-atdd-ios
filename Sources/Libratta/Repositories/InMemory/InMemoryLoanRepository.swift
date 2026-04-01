import Foundation

public final class InMemoryLoanRepository: LoanRepository, @unchecked Sendable {
    private var loans: [String: Loan] = [:]

    public init() {}

    public func save(_ loan: Loan) throws {
        loans[loan.id] = loan
    }

    public func findById(_ id: String) -> Loan? {
        loans[id]
    }

    public func findByMemberId(_ memberId: String) -> [Loan] {
        loans.values.filter { $0.memberId == memberId }
    }

    public func findByBookId(_ bookId: String) -> Loan? {
        loans.values.first { $0.bookId == bookId }
    }

    public func findActiveByBookId(_ bookId: String) -> Loan? {
        loans.values.first { $0.bookId == bookId }
    }

    public func findAll() -> [Loan] {
        Array(loans.values)
    }

    public func countActiveByMemberId(_ memberId: String) -> Int {
        loans.values.filter { $0.memberId == memberId }.count
    }

    public func findBorrowedBookIds() -> Set<String> {
        Set(loans.values.map { $0.bookId })
    }

    public func delete(_ id: String) {
        loans.removeValue(forKey: id)
    }

    public func clear() {
        loans.removeAll()
    }
}
