import XCTest
@testable import Libratta

final class ScenarioContext: @unchecked Sendable {
    // MARK: - Repositories
    var memberRepo: InMemoryMemberRepository!
    var bookRepo: InMemoryBookRepository!
    var loanRepo: InMemoryLoanRepository!
    var sessionRepo: InMemorySessionRepository!

    // MARK: - Use Cases
    var borrowUseCase: BorrowBookUseCase!
    var returnUseCase: ReturnBookUseCase!
    var searchBooksUseCase: SearchBooksUseCase!
    var registerBookUseCase: RegisterBookUseCase!
    var registerMemberUseCase: RegisterMemberUseCase!
    var listMembersUseCase: ListMembersUseCase!
    var sessionManager: SessionManager!

    // MARK: - Auth
    var stubAuth: StubAuthRepository!
    var loginUseCase: LoginUseCase!

    // MARK: - Results
    var borrowResult: BorrowBookResult?
    var returnResult: ReturnBookResult?
    var loginResult: LoginResult?
    var registerBookResult: RegisterBookResult?
    var registerMemberResult: RegisterMemberResult?
    var bookList: [Book] = []
    var searchResults: [Book] = []
    var memberList: [Member] = []
    var memberSearchResults: [Member] = []
    var loanSearchResults: [Loan] = []
    var errorMessage: String?
    var apiStatusCode: Int?
    var apiResponseBody: [String: Any]?

    func reset() {
        memberRepo = InMemoryMemberRepository()
        bookRepo = InMemoryBookRepository()
        loanRepo = InMemoryLoanRepository()
        sessionRepo = InMemorySessionRepository()
        stubAuth = StubAuthRepository()

        borrowUseCase = nil
        returnUseCase = nil
        searchBooksUseCase = nil
        registerBookUseCase = nil
        registerMemberUseCase = nil
        listMembersUseCase = nil
        sessionManager = nil
        loginUseCase = nil

        borrowResult = nil
        returnResult = nil
        loginResult = nil
        registerBookResult = nil
        registerMemberResult = nil
        bookList = []
        searchResults = []
        memberList = []
        memberSearchResults = []
        loanSearchResults = []
        errorMessage = nil
        apiStatusCode = nil
        apiResponseBody = nil
    }

    // MARK: - Lazy Use Case Initializers

    func ensureBorrowUseCase() {
        if borrowUseCase == nil {
            borrowUseCase = BorrowBookUseCase(
                memberRepository: memberRepo,
                bookRepository: bookRepo,
                loanRepository: loanRepo
            )
        }
    }

    func ensureReturnUseCase() {
        if returnUseCase == nil {
            returnUseCase = ReturnBookUseCase(
                memberRepository: memberRepo,
                bookRepository: bookRepo,
                loanRepository: loanRepo
            )
        }
    }

    func ensureSearchBooksUseCase() {
        if searchBooksUseCase == nil {
            searchBooksUseCase = SearchBooksUseCase(
                bookRepository: bookRepo,
                loanRepository: loanRepo
            )
        }
    }
}
