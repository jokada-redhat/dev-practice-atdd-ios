import Foundation

public final class InMemoryMemberRepository: MemberRepository, @unchecked Sendable {
    private var members: [String: Member] = [:]

    public init() {}

    public func save(_ member: Member) throws {
        if let existing = findByEmail(member.email), existing.id != member.id {
            throw RepositoryError.duplicateEmail
        }
        members[member.id] = member
    }

    public func findById(_ id: String) -> Member? {
        members[id]
    }

    public func findByEmail(_ email: String) -> Member? {
        members.values.first { $0.email == email }
    }

    public func findAll() -> [Member] {
        Array(members.values)
    }

    public func search(_ query: String) -> [Member] {
        let lowered = query.lowercased()
        return members.values.filter {
            $0.name.lowercased().contains(lowered) ||
            $0.email.lowercased().contains(lowered) ||
            $0.id.lowercased().contains(lowered)
        }
    }

    public func updateLoanCount(id: String, loanCount: Int) throws {
        guard var member = members[id] else {
            throw RepositoryError.notFound
        }
        member.loanCount = loanCount
        members[id] = member
    }

    public func delete(_ id: String) {
        members.removeValue(forKey: id)
    }

    public func clear() {
        members.removeAll()
    }
}
