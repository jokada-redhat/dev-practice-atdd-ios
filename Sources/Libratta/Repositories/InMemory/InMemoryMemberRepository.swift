import Foundation

public final class InMemoryMemberRepository: MemberRepository, @unchecked Sendable {
    private var members: [String: Member] = [:]

    public init() {}

    public func save(_ member: Member) throws {
        members[member.id] = member
    }

    public func findById(_ id: String) -> Member? {
        members[id]
    }

    public func findAll() -> [Member] {
        Array(members.values).sorted { $0.id < $1.id }
    }

    public func search(_ query: String) -> [Member] {
        let lowered = query.lowercased()
        return members.values.filter {
            $0.name.lowercased().contains(lowered) ||
            $0.id.lowercased().contains(lowered)
        }
    }

    public func delete(_ id: String) {
        members.removeValue(forKey: id)
    }

    public func clear() {
        members.removeAll()
    }
}
