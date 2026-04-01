import Foundation

public protocol SessionRepository: Sendable {
    func saveToken(_ token: String)
    func getToken() -> String?
    func saveDisplayName(_ displayName: String)
    func getDisplayName() -> String?
    func clear()
}
