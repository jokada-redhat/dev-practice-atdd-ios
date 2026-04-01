import XCTest
@testable import Libratta

/// Feature: 会員管理 (member_management.feature)
final class MemberManagementStepTests: XCTestCase {
    private var memberRepo: InMemoryMemberRepository!

    override func setUp() {
        memberRepo = InMemoryMemberRepository()
    }

    func test新規会員を登録する() {
        let useCase = RegisterMemberUseCase(memberRepository: memberRepo)
        let result = useCase.execute(name: "山田太郎", email: "taro@example.com")

        guard case let .success(member) = result else {
            XCTFail("登録が成功するべき")
            return
        }
        XCTAssertEqual(member.name, "山田太郎")
        XCTAssertEqual(member.loanCount, 0)
        XCTAssertTrue(memberRepo.findAll().contains { $0.name == "山田太郎" })
    }

    func test会員一覧を表示する() throws {
        try memberRepo.save(Member(id: "DA-8821", name: "Taro Yamada", email: "taro@example.com", loanCount: 2))
        try memberRepo.save(Member(id: "DA-1156", name: "Marcus Thorne", email: "marcus@example.com", loanCount: 0))
        try memberRepo.save(Member(id: "DA-5509", name: "Julian Chen", email: "julian@example.com", loanCount: 1))

        let useCase = ListMembersUseCase(memberRepository: memberRepo)
        let members = useCase.execute()

        XCTAssertEqual(members.count, 3)
    }

    func test会員を名前で検索する() throws {
        try memberRepo.save(Member(id: "DA-8821", name: "Taro Yamada", email: "taro@example.com", loanCount: 2))
        try memberRepo.save(Member(id: "DA-1156", name: "Marcus Thorne", email: "marcus@example.com", loanCount: 0))
        try memberRepo.save(Member(id: "DA-5509", name: "Julian Chen", email: "julian@example.com", loanCount: 1))

        let useCase = ListMembersUseCase(memberRepository: memberRepo)
        let results = useCase.search("Marcus")

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Marcus Thorne")
    }

    func testメールアドレスが重複している場合は登録できない() {
        let useCase = RegisterMemberUseCase(memberRepository: memberRepo)
        _ = useCase.execute(name: "山田太郎", email: "taro@example.com")
        let result = useCase.execute(name: "山田次郎", email: "taro@example.com")

        guard case let .error(message) = result else {
            XCTFail("エラーが返されるべき")
            return
        }
        XCTAssertEqual(message, "このメールアドレスは既に登録されています")
        XCTAssertFalse(memberRepo.findAll().contains { $0.name == "山田次郎" })
    }

    func test名前が空の場合は登録できない() {
        let useCase = RegisterMemberUseCase(memberRepository: memberRepo)
        let result = useCase.execute(name: "", email: "test@example.com")

        guard case let .validationError(message) = result else {
            XCTFail("バリデーションエラーが発生するべき")
            return
        }
        XCTAssertEqual(message, "名前を入力してください")
    }

    func testメールアドレスが空の場合は登録できない() {
        let useCase = RegisterMemberUseCase(memberRepository: memberRepo)
        let result = useCase.execute(name: "山田太郎", email: "")

        guard case let .validationError(message) = result else {
            XCTFail("バリデーションエラーが発生するべき")
            return
        }
        XCTAssertEqual(message, "メールアドレスを入力してください")
    }

    func testメールアドレスの形式が不正な場合は登録できない() {
        let useCase = RegisterMemberUseCase(memberRepository: memberRepo)
        let result = useCase.execute(name: "山田太郎", email: "invalid-email")

        guard case let .validationError(message) = result else {
            XCTFail("バリデーションエラーが発生するべき")
            return
        }
        XCTAssertEqual(message, "有効なメールアドレスを入力してください")
    }

    func test検索結果が0件の場合は空リストが返される() throws {
        try memberRepo.save(Member(id: "DA-8821", name: "Taro Yamada", email: "taro@example.com"))

        let useCase = ListMembersUseCase(memberRepository: memberRepo)
        let results = useCase.search("存在しない名前")

        XCTAssertEqual(results.count, 0)
    }

    func testIDで会員を検索する() throws {
        try memberRepo.save(Member(id: "DA-8821", name: "Taro Yamada", email: "taro@example.com"))
        try memberRepo.save(Member(id: "DA-1156", name: "Marcus Thorne", email: "marcus@example.com"))

        let useCase = ListMembersUseCase(memberRepository: memberRepo)
        let results = useCase.search("DA-8821")

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Taro Yamada")
    }
}
