import SwiftUI

struct LoanedItem: Identifiable {
    let id: String
    let loanId: String
    let bookTitle: String
    let bookIsbn: String
    let memberName: String
    let memberId: String
    let borrowedDate: Date
}

@MainActor
final class ReturnBookViewModel: ObservableObject {
    @Published var loanedItems: [LoanedItem] = []
    @Published var searchQuery = ""
    @Published var returnResult: String?
    @Published var showReturnAlert = false

    private let loanRepository: LoanRepository
    private let bookRepository: BookRepository
    private let memberRepository: MemberRepository
    private let returnBookUseCase: ReturnBookUseCase

    init(
        loanRepository: LoanRepository,
        bookRepository: BookRepository,
        memberRepository: MemberRepository,
        returnBookUseCase: ReturnBookUseCase
    ) {
        self.loanRepository = loanRepository
        self.bookRepository = bookRepository
        self.memberRepository = memberRepository
        self.returnBookUseCase = returnBookUseCase
    }

    func loadLoans() {
        let activeLoans = loanRepository.findAllActive()
        var items: [LoanedItem] = []

        for loan in activeLoans {
            guard let book = bookRepository.findById(loan.bookId),
                  let member = memberRepository.findById(loan.memberId) else { continue }

            items.append(LoanedItem(
                id: loan.id,
                loanId: loan.id,
                bookTitle: book.title,
                bookIsbn: book.isbn,
                memberName: member.name,
                memberId: member.id,
                borrowedDate: loan.borrowedDate
            ))
        }

        if searchQuery.isEmpty {
            loanedItems = items
        } else {
            let query = searchQuery.lowercased()
            loanedItems = items.filter {
                $0.bookTitle.lowercased().contains(query) ||
                $0.bookIsbn.lowercased().contains(query) ||
                $0.memberName.lowercased().contains(query) ||
                $0.memberId.lowercased().contains(query)
            }
        }
    }

    func returnBook(_ item: LoanedItem) {
        let result = returnBookUseCase.executeByLoanId(item.loanId)
        switch result {
        case .success:
            returnResult = nil
            loadLoans()
        case let .error(message):
            returnResult = message
            showReturnAlert = true
        }
    }
}
