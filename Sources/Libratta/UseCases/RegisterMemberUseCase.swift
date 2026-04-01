import Foundation

public enum RegisterMemberResult: Equatable {
    case success(Member)
    case validationError(message: String)
    case error(message: String)
}

public final class RegisterMemberUseCase: Sendable {
    private let memberRepository: MemberRepository

    public init(memberRepository: MemberRepository) {
        self.memberRepository = memberRepository
    }

    public func execute(name: String) -> RegisterMemberResult {
        if name.trimmingCharacters(in: .whitespaces).isEmpty {
            return .validationError(message: "名前を入力してください")
        }

        let memberId = generateMemberId()
        let member = Member(id: memberId, name: name)

        do {
            try memberRepository.save(member)
            return .success(member)
        } catch {
            return .error(message: "登録に失敗しました")
        }
    }

    private func generateMemberId() -> String {
        let number = Int.random(in: 1000...9999)
        return "DA-\(number)"
    }
}
