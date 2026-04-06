import XCTest
import CucumberSwift
import CucumberSwiftExpressions

extension Cucumber: StepImplementation {
    public var bundle: Bundle {
        class Findme {}
        return Bundle(for: Findme.self)
    }

    public func setupSteps() {
        let app = XCUIApplication()

        BeforeScenario { _ in
            app.terminate()
            app.launch()
        }

        registerLoginUISteps(app: app)
        registerNavigationUISteps(app: app)
        registerBookCatalogUISteps(app: app)
        registerBorrowingFlowUISteps(app: app)
    }
}
