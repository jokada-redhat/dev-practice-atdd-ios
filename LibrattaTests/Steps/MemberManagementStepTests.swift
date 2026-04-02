import XCTest
@testable import Libratta

/// Feature: 会員管理 (member_management.feature)
final class MemberManagementStepTests: XCTestCase {
    private var memberRepo: InMemoryMemberRepository!
    private var loanRepo: InMemoryLoanRepository!

    override func setUp() {
        memberRepo = InMemoryMemberRepository()
        loanRepo = InMemoryLoanRepository()
    }

    func testSmoke_新規会員を登録する() {
        let useCase = RegisterMemberUseCase(memberRepository: memberRepo)
        let result = useCase.execute(name: "山田太郎")

        guard case let .success(member) = result else {
            XCTFail("登録が成功するべき")
            return
        }
        XCTAssertEqual(member.name, "山田太郎")
        XCTAssertEqual(loanRepo.countActiveByMemberId(member.id), 0)
        XCTAssertTrue(memberRepo.findAll().contains { $0.name == "山田太郎" })
    }

    func test会員一覧を表示する() throws {
        try memberRepo.save(Member(id: "DA-8821", name: "Taro Yamada"))
        try memberRepo.save(Member(id: "DA-1156", name: "Marcus Thorne"))
        try memberRepo.save(Member(id: "DA-5509", name: "Julian Chen"))

        let useCase = ListMembersUseCase(memberRepository: memberRepo)
        let members = useCase.execute()

        XCTAssertEqual(members.count, 3)
    }

    func test会員を名前で検索する() throws {
        try memberRepo.save(Member(id: "DA-8821", name: "Taro Yamada"))
        try memberRepo.save(Member(id: "DA-1156", name: "Marcus Thorne"))
        try memberRepo.save(Member(id: "DA-5509", name: "Julian Chen"))

        let useCase = ListMembersUseCase(memberRepository: memberRepo)
        let results = useCase.search("Marcus")

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Marcus Thorne")
    }

    func test名前が空の場合は登録できない() {
        let useCase = RegisterMemberUseCase(memberRepository: memberRepo)
        let result = useCase.execute(name: "")

        guard case let .validationError(message) = result else {
            XCTFail("バリデーションエラーが発生するべき")
            return
        }
        XCTAssertEqual(message, "名前を入力してください")
    }

    func test検索結果が0件の場合は空リストが返される() throws {
        try memberRepo.save(Member(id: "DA-8821", name: "Taro Yamada"))

        let useCase = ListMembersUseCase(memberRepository: memberRepo)
        let results = useCase.search("存在しない名前")

        XCTAssertEqual(results.count, 0)
    }

    func testIDで会員を検索する() throws {
        try memberRepo.save(Member(id: "DA-8821", name: "Taro Yamada"))
        try memberRepo.save(Member(id: "DA-1156", name: "Marcus Thorne"))

        let useCase = ListMembersUseCase(memberRepository: memberRepo)
        let results = useCase.search("DA-8821")

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Taro Yamada")
    }
}
