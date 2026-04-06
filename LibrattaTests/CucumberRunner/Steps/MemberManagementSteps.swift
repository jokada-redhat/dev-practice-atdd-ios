import XCTest
import CucumberSwift
import CucumberSwiftExpressions
@testable import Libratta

extension Cucumber {
    // swiftlint:disable:next function_body_length
    func registerMemberManagementSteps(context: ScenarioContext) {
        Given("会員リストが空である") { _, _ in }

        Given("以下の会員が登録されている:") { _, step in
            guard let rows = step.dataTable?.rows else { return }
            for row in rows.dropFirst() {
                try! context.memberRepo.save(Member(id: row[0], name: row[1])) // swiftlint:disable:this force_try
            }
        }

        When("会員 {string} を登録する" as CucumberExpression) { matches, _ in
            let name = try matches.first(\.string)
            let useCase = RegisterMemberUseCase(memberRepository: context.memberRepo)
            context.registerMemberResult = useCase.execute(name: name)
        }

        When("会員一覧を取得する") { _, _ in
            let useCase = ListMembersUseCase(memberRepository: context.memberRepo)
            context.memberList = useCase.execute()
        }

        When("会員を {string} で検索する" as CucumberExpression) { matches, _ in
            let query = try matches.first(\.string)
            let useCase = ListMembersUseCase(memberRepository: context.memberRepo)
            context.memberSearchResults = useCase.search(query)
        }

        When("名前が空で登録しようとする") { _, _ in
            let useCase = RegisterMemberUseCase(memberRepository: context.memberRepo)
            context.registerMemberResult = useCase.execute(name: "")
        }

        Then("会員リストに {string} が含まれている" as CucumberExpression) { matches, _ in
            let name = try matches.first(\.string)
            XCTAssertTrue(context.memberRepo.findAll().contains { $0.name == name })
        }

        Then("会員 {string} の貸出冊数は {int} である" as CucumberExpression) { matches, _ in
            let name = try matches.first(\.string)
            let count = try matches.last(\.int)
            let member = context.memberRepo.findAll().first { $0.name == name }
            XCTAssertNotNil(member)
            XCTAssertEqual(context.loanRepo.countActiveByMemberId(member!.id), count)
        }

        Then("会員リストに {int} 件の会員が含まれている" as CucumberExpression) { matches, _ in
            let count = try matches.first(\.int)
            XCTAssertEqual(context.memberList.count, count)
        }

        Then("会員リストの先頭は {string} である" as CucumberExpression) { matches, _ in
            let name = try matches.first(\.string)
            XCTAssertEqual(context.memberList.first?.name, name)
        }

        Then("検索結果に {int} 件の会員が含まれている" as CucumberExpression) { matches, _ in
            let count = try matches.first(\.int)
            XCTAssertEqual(context.memberSearchResults.count, count)
        }

        Then("会員検索結果に {string} が含まれている" as CucumberExpression) { matches, _ in
            let name = try matches.first(\.string)
            XCTAssertTrue(context.memberSearchResults.contains { $0.name == name })
        }

        Then("バリデーションエラー {string} が返される" as CucumberExpression) { matches, _ in
            let expected = try matches.first(\.string)
            if let result = context.registerMemberResult {
                guard case let .validationError(message) = result else {
                    XCTFail("バリデーションエラーが発生するべき"); return
                }
                XCTAssertEqual(message, expected)
            }
        }
    }
}
