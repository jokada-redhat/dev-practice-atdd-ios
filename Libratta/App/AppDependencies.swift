import Foundation

@MainActor
final class AppDependencies: ObservableObject {
    let memberRepository: InMemoryMemberRepository
    let bookRepository: InMemoryBookRepository
    let loanRepository: InMemoryLoanRepository
    let sessionManager: SessionManager
    let authRepository: StubAuthRepository
    let isDebugMode: Bool

    init() {
        #if DEBUG
        isDebugMode = true
        #else
        isDebugMode = false
        #endif
        memberRepository = InMemoryMemberRepository()
        bookRepository = InMemoryBookRepository()
        loanRepository = InMemoryLoanRepository()

        let sessionRepo = InMemorySessionRepository()
        sessionManager = SessionManager(repository: sessionRepo)

        authRepository = StubAuthRepository()
        authRepository.registerUser(
            email: "librarian@example.com",
            password: "password",
            displayName: "司書 太郎"
        )

        let generator = DummyDataGenerator(
            memberRepository: memberRepository,
            bookRepository: bookRepository,
            loanRepository: loanRepository
        )
        generator.generate()

        if ProcessInfo.processInfo.arguments.contains("--set-borrowing-limit-test") {
            setupBorrowingLimitTest()
        }
    }

    private func setupBorrowingLimitTest() {
        let memberId = "DA-0001"
        let borrowUseCase = BorrowBookUseCase(
            memberRepository: memberRepository,
            bookRepository: bookRepository,
            loanRepository: loanRepository
        )
        let availableBooks = bookRepository.findAll().filter { book in
            loanRepository.findActiveByBookId(book.id) == nil
        }
        let currentCount = loanRepository.countActiveByMemberId(memberId)
        let needed = 3 - currentCount
        for book in availableBooks.prefix(needed) {
            _ = borrowUseCase.execute(memberId: memberId, bookTitle: book.title)
        }
    }

    // MARK: - UseCases

    var loginUseCase: LoginUseCase {
        LoginUseCase(authRepository: authRepository)
    }

    var registerMemberUseCase: RegisterMemberUseCase {
        RegisterMemberUseCase(memberRepository: memberRepository)
    }

    var listMembersUseCase: ListMembersUseCase {
        ListMembersUseCase(memberRepository: memberRepository)
    }

    var searchBooksUseCase: SearchBooksUseCase {
        SearchBooksUseCase(bookRepository: bookRepository, loanRepository: loanRepository)
    }

    var registerBookUseCase: RegisterBookUseCase {
        RegisterBookUseCase(bookRepository: bookRepository)
    }

    var borrowBookUseCase: BorrowBookUseCase {
        BorrowBookUseCase(
            memberRepository: memberRepository,
            bookRepository: bookRepository,
            loanRepository: loanRepository
        )
    }

    var returnBookUseCase: ReturnBookUseCase {
        ReturnBookUseCase(
            memberRepository: memberRepository,
            bookRepository: bookRepository,
            loanRepository: loanRepository
        )
    }

    // MARK: - ViewModels

    func makeLoginViewModel() -> LoginViewModel {
        LoginViewModel(
            loginUseCase: loginUseCase,
            sessionManager: sessionManager,
            isDebugMode: isDebugMode
        )
    }

    func makeTopViewModel() -> TopViewModel {
        TopViewModel(sessionManager: sessionManager)
    }

    func makeMemberListViewModel() -> MemberListViewModel {
        MemberListViewModel(
            listMembersUseCase: listMembersUseCase,
            loanRepository: loanRepository
        )
    }

    func makeAddMemberViewModel() -> AddMemberViewModel {
        AddMemberViewModel(registerMemberUseCase: registerMemberUseCase)
    }

    func makeBookCatalogViewModel() -> BookCatalogViewModel {
        BookCatalogViewModel(
            searchBooksUseCase: searchBooksUseCase,
            borrowBookUseCase: borrowBookUseCase,
            loanRepository: loanRepository
        )
    }

    func makeBookListViewModel() -> BookListViewModel {
        BookListViewModel(searchBooksUseCase: searchBooksUseCase)
    }

    func makeAddBookViewModel() -> AddBookViewModel {
        AddBookViewModel(registerBookUseCase: registerBookUseCase)
    }

    func makeReturnBookViewModel() -> ReturnBookViewModel {
        ReturnBookViewModel(
            loanRepository: loanRepository,
            bookRepository: bookRepository,
            memberRepository: memberRepository,
            returnBookUseCase: returnBookUseCase
        )
    }
}
