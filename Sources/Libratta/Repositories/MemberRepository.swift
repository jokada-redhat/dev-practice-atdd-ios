import Foundation

public protocol MemberRepository: Sendable {
    func save(_ member: Member) throws
    func findById(_ id: String) -> Member?
    func findAll() -> [Member]
    func search(_ query: String) -> [Member]
    func delete(_ id: String)
    func clear()
}
