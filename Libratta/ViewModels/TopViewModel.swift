import SwiftUI

@MainActor
final class TopViewModel: ObservableObject {
    @Published var displayName: String = ""

    private let sessionManager: SessionManager

    init(sessionManager: SessionManager) {
        self.sessionManager = sessionManager
        self.displayName = sessionManager.displayName ?? ""
    }

    func logout() {
        sessionManager.clearSession()
    }

    var isLoggedIn: Bool {
        sessionManager.isLoggedIn
    }
}
