import Foundation

public enum BorrowBookResult: Equatable {
    case success(Loan)
    case error(message: String)
}

public final class BorrowBookUseCase: Sendable {
    private static let borrowingLimit = 3

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
        guard memberRepository.findById(memberId) != nil else {
            return .error(message: "会員が見つかりません")
        }

        let activeLoanCount = loanRepository.countActiveByMemberId(memberId)
        if activeLoanCount >= Self.borrowingLimit {
            return .error(message: "貸出上限（\(Self.borrowingLimit)冊）に達しています")
        }

        guard let book = bookRepository.findByTitle(bookTitle) else {
            return .error(message: "書籍が見つかりません")
        }

        if loanRepository.findActiveByBookId(book.id) != nil {
            return .error(message: "この書籍は既に貸出中です")
        }

        let loan = Loan(memberId: memberId, bookId: book.id)

        do {
            try loanRepository.save(loan)
            return .success(loan)
        } catch {
            return .error(message: "貸出処理に失敗しました")
        }
    }
}
