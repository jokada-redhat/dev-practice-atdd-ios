import Foundation

public enum BorrowBookResult: Equatable {
    case success(Loan)
    case error(message: String)
}

public final class BorrowBookUseCase: Sendable {
    private let memberRepository: MemberRepository
    private let bookRepository: BookRepository
    private let loanRepository: LoanRepository

    public init(
        memberRepository: MemberRepository,
        bookRepository: BookRepository,
        loanRepository: LoanRepository
    ) {
        self.memberRepository = memberRepository
        self.bookRepository = bookRepository
        self.loanRepository = loanRepository
    }

    public func execute(memberId: String, bookTitle: String) -> BorrowBookResult {
        guard let member = memberRepository.findById(memberId) else {
            return .error(message: "会員が見つかりません")
        }

        guard let book = bookRepository.findByTitle(bookTitle) else {
            return .error(message: "書籍が見つかりません")
        }

        guard book.isAvailable else {
            return .error(message: "この書籍は既に貸出中です")
        }

        let loan = Loan(memberId: member.id, bookId: book.id)

        do {
            try loanRepository.save(loan)
            try bookRepository.updateStatus(id: book.id, status: .borrowed)
            try memberRepository.updateLoanCount(id: member.id, loanCount: member.loanCount + 1)
            return .success(loan)
        } catch {
            // Rollback
            loanRepository.delete(loan.id)
            try? bookRepository.updateStatus(id: book.id, status: .available)
            return .error(message: "貸出処理に失敗しました")
        }
    }
}
