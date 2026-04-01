import SwiftUI

@MainActor
final class MemberListViewModel: ObservableObject {
    @Published var members: [Member] = []
    @Published var searchQuery = ""

    private let listMembersUseCase: ListMembersUseCase

    init(listMembersUseCase: ListMembersUseCase) {
        self.listMembersUseCase = listMembersUseCase
    }

    func loadMembers() {
        if searchQuery.isEmpty {
            members = listMembersUseCase.execute()
        } else {
            members = listMembersUseCase.search(searchQuery)
        }
    }
}
