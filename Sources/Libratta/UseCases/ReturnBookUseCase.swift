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

        guard let member = memberRepository.findById(memberId) else {
            return .error(message: "会員が見つかりません")
        }

        do {
            try loanRepository.returnBook(loan.id)
            try bookRepository.updateStatus(id: book.id, status: .available)
            try memberRepository.updateLoanCount(id: member.id, loanCount: max(0, member.loanCount - 1))

            if let updatedLoan = loanRepository.findById(loan.id) {
                return .success(updatedLoan)
            }
            return .success(loan)
        } catch {
            return .error(message: "返却処理に失敗しました")
        }
    }

    public func executeByLoanId(_ loanId: String) -> ReturnBookResult {
        guard let loan = loanRepository.findById(loanId), !loan.isReturned else {
            return .error(message: "貸出記録が見つかりません")
        }

        guard let book = bookRepository.findById(loan.bookId) else {
            return .error(message: "書籍が見つかりません")
        }

        guard let member = memberRepository.findById(loan.memberId) else {
            return .error(message: "会員が見つかりません")
        }

        do {
            try loanRepository.returnBook(loan.id)
            try bookRepository.updateStatus(id: book.id, status: .available)
            try memberRepository.updateLoanCount(id: member.id, loanCount: max(0, member.loanCount - 1))

            if let updatedLoan = loanRepository.findById(loan.id) {
                return .success(updatedLoan)
            }
            return .success(loan)
        } catch {
            return .error(message: "返却処理に失敗しました")
        }
    }
}
