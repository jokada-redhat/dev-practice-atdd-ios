import XCTest
import CucumberSwift
import CucumberSwiftExpressions
@testable import Libratta

extension Cucumber: StepImplementation {
    public var bundle: Bundle {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        class Findme {}
        return Bundle(for: Findme.self)
        #endif
    }

    public func setupSteps() {
        let context = ScenarioContext()

        BeforeScenario { _ in
            context.reset()
        }

        registerSharedSteps(context: context)
        registerSessionSteps(context: context)
        registerMemberManagementSteps(context: context)
        registerBookManagementSteps(context: context)
        registerBookCatalogSteps(context: context)
        registerBorrowingFlowSteps(context: context)
        registerReturnFromListSteps(context: context)
        registerReturnBookSteps(context: context)
        registerLoginSteps(context: context)
        registerLoginApiSteps(context: context)
    }
}
