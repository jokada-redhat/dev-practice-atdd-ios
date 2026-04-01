import SwiftUI

@main
struct LibrattaApp: App {
    @StateObject private var deps = AppDependencies()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(deps)
        }
    }
}
