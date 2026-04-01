import Foundation

public final class ListMembersUseCase: Sendable {
    private let memberRepository: MemberRepository

    public init(memberRepository: MemberRepository) {
        self.memberRepository = memberRepository
    }

    public func execute() -> [Member] {
        memberRepository.findAll()
    }

    public func search(_ query: String) -> [Member] {
        memberRepository.search(query)
    }
}
