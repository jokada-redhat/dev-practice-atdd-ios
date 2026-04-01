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

    public func execute(name: String, email: String, id: String? = nil) -> RegisterMemberResult {
        if name.trimmingCharacters(in: .whitespaces).isEmpty {
            return .validationError(message: "名前を入力してください")
        }
        if email.trimmingCharacters(in: .whitespaces).isEmpty {
            return .validationError(message: "メールアドレスを入力してください")
        }
        if !isValidEmail(email) {
            return .validationError(message: "有効なメールアドレスを入力してください")
        }

        let memberId = id ?? generateMemberId()
        let member = Member(id: memberId, name: name, email: email)

        do {
            try memberRepository.save(member)
            return .success(member)
        } catch RepositoryError.duplicateEmail {
            return .error(message: "このメールアドレスは既に登録されています")
        } catch {
            return .error(message: "登録に失敗しました")
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        email.contains("@") && email.contains(".")
    }

    private func generateMemberId() -> String {
        let number = Int.random(in: 1000...9999)
        return "DA-\(number)"
    }
}
