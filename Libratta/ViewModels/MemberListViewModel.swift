import SwiftUI

@MainActor
final class MemberListViewModel: ObservableObject {
    @Published var members: [Member] = []
    @Published var searchQuery = ""

    private let listMembersUseCase: ListMembersUseCase
    let loanRepository: LoanRepository

    init(listMembersUseCase: ListMembersUseCase, loanRepository: LoanRepository) {
        self.listMembersUseCase = listMembersUseCase
        self.loanRepository = loanRepository
    }

    func loadMembers() {
        if searchQuery.isEmpty {
            members = listMembersUseCase.execute()
        } else {
            members = listMembersUseCase.search(searchQuery)
        }
    }

    func loanCount(for member: Member) -> Int {
        loanRepository.countActiveByMemberId(member.id)
    }
}
