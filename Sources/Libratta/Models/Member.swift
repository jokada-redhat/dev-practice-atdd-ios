import Foundation

public struct Member: Equatable, Identifiable, Sendable {
    public let id: String
    public let name: String
    public let email: String
    public let phone: String?
    public let address: String?
    public var loanCount: Int

    public init(
        id: String,
        name: String,
        email: String,
        phone: String? = nil,
        address: String? = nil,
        loanCount: Int = 0
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.phone = phone
        self.address = address
        self.loanCount = loanCount
    }
}
