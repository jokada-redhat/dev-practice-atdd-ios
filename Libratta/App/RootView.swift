import SwiftUI

enum AppRoute: Hashable {
    case memberList
    case bookCatalog(memberId: String, memberName: String)
    case loanConfirmation(memberName: String, bookTitle: String)
    case returnBook
    case bookList
    case debugSettings
}

struct RootView: View {
    @EnvironmentObject var deps: AppDependencies
    @State private var isLoggedIn = false
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            if isLoggedIn {
                TopView(
                    viewModel: deps.makeTopViewModel(),
                    onLogout: {
                        isLoggedIn = false
                        path = NavigationPath()
                    },
                    onBorrowing: {
                        path.append(AppRoute.memberList)
                    },
                    onReturns: {
                        path.append(AppRoute.returnBook)
                    },
                    onBookList: {
                        path.append(AppRoute.bookList)
                    },
                    onDebugSettings: deps.isDebugMode ? {
                        path.append(AppRoute.debugSettings)
                    } : nil
                )
                .navigationDestination(for: AppRoute.self) { route in
                    destinationView(for: route)
                }
            } else {
                LoginView(
                    viewModel: deps.makeLoginViewModel(),
                    onLoginSuccess: {
                        isLoggedIn = true
                    }
                )
            }
        }
    }

    @ViewBuilder
    private func destinationView(for route: AppRoute) -> some View {
        switch route {
        case .memberList:
            MemberListView(
                viewModel: deps.makeMemberListViewModel(),
                onMemberSelected: { member in
                    path.append(AppRoute.bookCatalog(memberId: member.id, memberName: member.name))
                },
                addMemberViewModelFactory: { deps.makeAddMemberViewModel() }
            )
        case let .bookCatalog(memberId, _):
            makeBookCatalogView(memberId: memberId)
        case let .loanConfirmation(memberName, bookTitle):
            LoanConfirmationView(
                memberName: memberName,
                bookTitle: bookTitle,
                onDone: {
                    path = NavigationPath()
                }
            )
        case .returnBook:
            ReturnBookView(viewModel: deps.makeReturnBookViewModel())
        case .bookList:
            BookListView(
                viewModel: deps.makeBookListViewModel(),
                addBookViewModelFactory: { deps.makeAddBookViewModel() }
            )
        case .debugSettings:
            DebugSettingsView()
        }
    }

    private func makeBookCatalogView(memberId: String) -> BookCatalogView {
        let vm = deps.makeBookCatalogViewModel()
        if let member = deps.memberRepository.findById(memberId) {
            vm.selectedMember = member
        }
        return BookCatalogView(
            viewModel: vm,
            onLoanConfirmed: { member, book in
                path.append(AppRoute.loanConfirmation(memberName: member.name, bookTitle: book.title))
            }
        )
    }
}
