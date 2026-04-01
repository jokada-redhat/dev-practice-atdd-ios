import Foundation

public enum ReturnBookResult: Equatable {
    case success(Loan)
    case error(message: String)
}

public final class ReturnBookUseCase: Sendable {
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

    public func execute(memberId: String, bookTitle: String) -> ReturnBookResult {
        guard let book = bookRepository.findByTitle(bookTitle) else {
            return .error(message: "書籍が見つかりません")
        }

        guard let loan = loanRepository.findActiveByBookId(book.id) else {
            return .error(message: "この書籍は貸し出されていません")
        }

        if loan.memberId != memberId {
            return .error(message: "この書籍は別の会員が借りています")
        }

        loanRepository.delete(loan.id)
        return .success(loan)
    }

    public func executeByLoanId(_ loanId: String) -> ReturnBookResult {
        guard let loan = loanRepository.findById(loanId) else {
            return .error(message: "貸出記録が見つかりません")
        }

        loanRepository.delete(loan.id)
        return .success(loan)
    }
}
