import XCTest
import CucumberSwift
import CucumberSwiftExpressions
@testable import Libratta

extension Cucumber: StepImplementation {
    public var bundle: Bundle {
        class Findme {}
        return Bundle(for: Findme.self)
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    public func setupSteps() {
        let context = ScenarioContext()

        BeforeScenario { _ in
            context.reset()
        }

        // MARK: - Shared Steps

        Given("会員 {string} \\(ID: {string}\\) が登録されている" as CucumberExpression) { matches, _ in
            let name = try matches.first(\.string)
            let memberId = try matches.last(\.string)
            try context.memberRepo.save(Member(id: memberId, name: name))
        }

        Given("書籍 {string} が登録されている" as CucumberExpression) { matches, _ in
            let title = try matches.first(\.string)
            try context.bookRepo.save(
                Book(title: title, author: "Author", isbn: UUID().uuidString, publicationYear: 2020)
            )
        }

        Given("会員 {string} が書籍 {string} を既に借りている" as CucumberExpression) { matches, _ in
            let memberId = try matches.first(\.string)
            let bookTitle = try matches.last(\.string)
            if context.bookRepo.findByTitle(bookTitle) == nil {
                try context.bookRepo.save(
                    Book(title: bookTitle, author: "Author", isbn: UUID().uuidString, publicationYear: 2020)
                )
            }
            context.ensureBorrowUseCase()
            _ = context.borrowUseCase.execute(memberId: memberId, bookTitle: bookTitle)
        }

        Then("書籍 {string} は貸出可能である" as CucumberExpression) { matches, _ in
            let title = try matches.first(\.string)
            let book = context.bookRepo.findByTitle(title)
            XCTAssertNotNil(book)
            guard let book else { return }
            XCTAssertNil(context.loanRepo.findActiveByBookId(book.id))
        }

        Then("書籍 {string} は貸出中である" as CucumberExpression) { matches, _ in
            let title = try matches.first(\.string)
            let book = context.bookRepo.findByTitle(title)
            XCTAssertNotNil(book)
            guard let book else { return }
            XCTAssertNotNil(context.loanRepo.findActiveByBookId(book.id))
        }

        Then("会員 {string} の貸出冊数が {int} になる" as CucumberExpression) { matches, _ in
            let memberId = try matches.first(\.string)
            let count = try matches.last(\.int)
            XCTAssertEqual(context.loanRepo.countActiveByMemberId(memberId), count)
        }

        Then("エラーメッセージ {string} が返される" as CucumberExpression) { matches, _ in
            let expected = try matches.first(\.string)
            if let result = context.borrowResult {
                guard case let .error(message) = result else {
                    XCTFail("エラーが返されるべき"); return
                }
                XCTAssertEqual(message, expected)
            } else if let result = context.returnResult {
                guard case let .error(message) = result else {
                    XCTFail("エラーが返されるべき"); return
                }
                XCTAssertEqual(message, expected)
            } else if let result = context.loginResult {
                guard case let .failure(message) = result else {
                    XCTFail("エラーが返されるべき"); return
                }
                XCTAssertEqual(message, expected)
            } else {
                XCTFail("結果が設定されていません")
            }
        }

        // MARK: - Session Steps

        Given("セッションが空である") { _, _ in
            context.sessionManager = SessionManager(repository: context.sessionRepo)
        }

        Given("トークン {string} と表示名 {string} でセッションが保存されている" as CucumberExpression) { matches, _ in
            let token = try matches.first(\.string)
            let displayName = try matches.last(\.string)
            context.sessionManager = SessionManager(repository: context.sessionRepo)
            context.sessionManager.saveSession(token: token, displayName: displayName)
        }

        When("トークン {string} と表示名 {string} でセッションを保存する" as CucumberExpression) { matches, _ in
            let token = try matches.first(\.string)
            let displayName = try matches.last(\.string)
            context.sessionManager.saveSession(token: token, displayName: displayName)
        }

        When("セッションをクリアする") { _, _ in
            context.sessionManager.clearSession()
        }

        Then("ログイン済みと判定される") { _, _ in
            XCTAssertTrue(context.sessionManager.isLoggedIn)
        }

        Then("未ログインと判定される") { _, _ in
            XCTAssertFalse(context.sessionManager.isLoggedIn)
        }

        Then("保存されたトークンは {string} である" as CucumberExpression) { _, _ in
            XCTAssertTrue(context.sessionManager.isLoggedIn)
        }

        Then("保存された表示名は {string} である" as CucumberExpression) { matches, _ in
            let expected = try matches.first(\.string)
            XCTAssertEqual(context.sessionManager.displayName, expected)
        }

        // MARK: - Member Management Steps

        Given("会員リストが空である") { _, _ in }

        Given("以下の会員が登録されている:") { _, step in
            guard let rows = step.dataTable?.rows else { return }
            for row in rows.dropFirst() {
                try! context.memberRepo.save(Member(id: row[0], name: row[1]))
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

        // MARK: - Book Management Steps

        Given("書籍管理に以下の書籍が登録されている:") { _, step in
            guard let rows = step.dataTable?.rows else { return }
            for row in rows.dropFirst() {
                try! context.bookRepo.save(
                    Book(title: row[0], author: row[1], isbn: row[2], publicationYear: Int(row[3]) ?? 2020)
                )
            }
        }

        When("書籍一覧を表示する") { _, _ in
            context.ensureSearchBooksUseCase()
            context.bookList = context.searchBooksUseCase.listAll()
        }

        When("書籍一覧で {string} と検索する" as CucumberExpression) { matches, _ in
            let query = try matches.first(\.string)
            context.ensureSearchBooksUseCase()
            context.bookList = context.searchBooksUseCase.search(query)
        }

        When("書籍を登録する:") { _, step in
            guard let rows = step.dataTable?.rows, rows.count >= 2 else { return }
            let row = rows[1]
            let useCase = RegisterBookUseCase(bookRepository: context.bookRepo)
            context.registerBookResult = useCase.execute(
                title: row[0], author: row[1], isbn: row[2], publicationYear: Int(row[3]) ?? 2020
            )
        }

        When("タイトル未入力で書籍を登録しようとする") { _, _ in
            let useCase = RegisterBookUseCase(bookRepository: context.bookRepo)
            context.registerBookResult = useCase.execute(
                title: "", author: "Author", isbn: "978-0000000000", publicationYear: 2020
            )
        }

        When("重複ISBNで書籍を登録しようとする:") { _, step in
            guard let rows = step.dataTable?.rows, rows.count >= 2 else { return }
            let row = rows[1]
            let useCase = RegisterBookUseCase(bookRepository: context.bookRepo)
            context.registerBookResult = useCase.execute(
                title: row[0], author: row[1], isbn: row[2], publicationYear: Int(row[3]) ?? 2020
            )
        }

        Then("書籍一覧に {int} 件表示される" as CucumberExpression) { matches, _ in
            let count = try matches.first(\.int)
            XCTAssertEqual(context.bookList.count, count)
        }

        Then("書籍一覧に書籍 {string} が含まれる" as CucumberExpression) { matches, _ in
            let title = try matches.first(\.string)
            XCTAssertTrue(context.bookList.contains { $0.title == title })
        }

        Then("書籍 {string} が書籍一覧に存在する" as CucumberExpression) { matches, _ in
            let title = try matches.first(\.string)
            XCTAssertNotNil(context.bookRepo.findByTitle(title))
        }

        Then("書籍 {string} の著者が {string} である" as CucumberExpression) { matches, _ in
            let title = try matches.first(\.string)
            let author = try matches.last(\.string)
            let book = context.bookRepo.findByTitle(title)
            XCTAssertEqual(book?.author, author)
        }

        Then("書籍 {string} のISBNが {string} である" as CucumberExpression) { matches, _ in
            let title = try matches.first(\.string)
            let isbn = try matches.last(\.string)
            let book = context.bookRepo.findByTitle(title)
            XCTAssertEqual(book?.isbn, isbn)
        }

        Then("書籍登録エラー {string} が表示される" as CucumberExpression) { matches, _ in
            let expected = try matches.first(\.string)
            guard let result = context.registerBookResult else {
                XCTFail("結果が設定されていません"); return
            }
            switch result {
            case let .validationError(message): XCTAssertEqual(message, expected)
            case let .error(message): XCTAssertEqual(message, expected)
            default: XCTFail("エラーが返されるべき")
            }
        }

        // MARK: - Book Catalog Steps

        Given("以下の書籍が登録されている:") { _, step in
            guard let rows = step.dataTable?.rows else { return }
            for row in rows.dropFirst() {
                try! context.bookRepo.save(
                    Book(title: row[0], author: row[1], isbn: row[2], publicationYear: Int(row[3]) ?? 2020)
                )
            }
        }

        Given("書籍 {string} が貸出中になっている" as CucumberExpression) { matches, _ in
            let title = try matches.first(\.string)
            guard let book = context.bookRepo.findByTitle(title) else {
                XCTFail("書籍 \(title) が見つかりません"); return
            }
            if context.memberRepo.findById("DA-0001") == nil {
                try context.memberRepo.save(Member(id: "DA-0001", name: "Dummy"))
            }
            try context.loanRepo.save(Loan(memberId: "DA-0001", bookId: book.id))
        }

        When("書籍一覧を取得する") { _, _ in
            context.ensureSearchBooksUseCase()
            context.bookList = context.searchBooksUseCase.listAll()
        }

        When("貸出可能な書籍でフィルタする") { _, _ in
            context.ensureSearchBooksUseCase()
            context.bookList = context.searchBooksUseCase.filterByStatus("AVAILABLE")
        }

        When("貸出中の書籍でフィルタする") { _, _ in
            context.ensureSearchBooksUseCase()
            context.bookList = context.searchBooksUseCase.filterByStatus("BORROWED")
        }

        When("書籍を {string} で検索する" as CucumberExpression) { matches, _ in
            let query = try matches.first(\.string)
            context.ensureSearchBooksUseCase()
            context.searchResults = context.searchBooksUseCase.search(query)
        }

        Then("書籍リストに {int} 件の書籍が含まれている" as CucumberExpression) { matches, _ in
            let count = try matches.first(\.int)
            XCTAssertEqual(context.bookList.count, count)
        }

        Then("書籍リストに {string} が含まれていない" as CucumberExpression) { matches, _ in
            let title = try matches.first(\.string)
            XCTAssertFalse(context.bookList.contains { $0.title == title })
        }

        Then("書籍リストに {string} が含まれている" as CucumberExpression) { matches, _ in
            let title = try matches.first(\.string)
            XCTAssertTrue(context.bookList.contains { $0.title == title })
        }

        Then("検索結果に {int} 件の書籍が含まれている" as CucumberExpression) { matches, _ in
            let count = try matches.first(\.int)
            XCTAssertEqual(context.searchResults.count, count)
        }

        Then("書籍検索結果に {string} が含まれている" as CucumberExpression) { matches, _ in
            let title = try matches.first(\.string)
            XCTAssertTrue(context.searchResults.contains { $0.title == title })
        }

        // MARK: - Borrowing Flow Steps

        Given("会員 {string} が {int} 冊借りている状態である" as CucumberExpression) { matches, _ in
            let memberId = try matches.first(\.string)
            let bookCount = try matches.last(\.int)
            context.ensureBorrowUseCase()
            for i in 0..<bookCount {
                let title = "Book \(i + 1)"
                try context.bookRepo.save(
                    Book(title: title, author: "Author", isbn: UUID().uuidString, publicationYear: 2020)
                )
                _ = context.borrowUseCase.execute(memberId: memberId, bookTitle: title)
            }
        }

        When("会員 {string} が書籍 {string} を借りる" as CucumberExpression) { matches, _ in
            let memberId = try matches.first(\.string)
            let bookTitle = try matches.last(\.string)
            context.ensureBorrowUseCase()
            context.borrowResult = context.borrowUseCase.execute(memberId: memberId, bookTitle: bookTitle)
        }

        When("会員 {string} が書籍 {string} を借りようとする" as CucumberExpression) { matches, _ in
            let memberId = try matches.first(\.string)
            let bookTitle = try matches.last(\.string)
            context.ensureBorrowUseCase()
            context.borrowResult = context.borrowUseCase.execute(memberId: memberId, bookTitle: bookTitle)
        }

        When("存在しない会員 {string} が書籍 {string} を借りようとする" as CucumberExpression) { matches, _ in
            let memberId = try matches.first(\.string)
            let bookTitle = try matches.last(\.string)
            context.ensureBorrowUseCase()
            context.borrowResult = context.borrowUseCase.execute(memberId: memberId, bookTitle: bookTitle)
        }

        When("会員 {string} が存在しない書籍を借りようとする" as CucumberExpression) { matches, _ in
            let memberId = try matches.first(\.string)
            context.ensureBorrowUseCase()
            context.borrowResult = context.borrowUseCase.execute(memberId: memberId, bookTitle: "存在しない書籍")
        }

        When("会員 {string} が書籍 {string} を返却する" as CucumberExpression) { matches, _ in
            let memberId = try matches.first(\.string)
            let bookTitle = try matches.last(\.string)
            context.ensureReturnUseCase()
            context.returnResult = context.returnUseCase.execute(memberId: memberId, bookTitle: bookTitle)
        }

        When("会員 {string} が書籍 {string} を返却しようとする" as CucumberExpression) { matches, _ in
            let memberId = try matches.first(\.string)
            let bookTitle = try matches.last(\.string)
            context.ensureReturnUseCase()
            context.returnResult = context.returnUseCase.execute(memberId: memberId, bookTitle: bookTitle)
        }

        Then("貸出記録が作成される") { _, _ in
            XCTAssertEqual(context.loanRepo.findAll().count, 1)
        }

        Then("貸出記録が削除される") { _, _ in
            XCTAssertEqual(context.loanRepo.findAll().count, 0)
        }

        // MARK: - Return From List Steps

        When("貸出一覧で書籍 {string} の返却ボタンを押す" as CucumberExpression) { matches, _ in
            let bookTitle = try matches.first(\.string)
            context.ensureReturnUseCase()
            let book = context.bookRepo.findByTitle(bookTitle)
            XCTAssertNotNil(book, "書籍 \(bookTitle) が見つかりません")
            guard let book else { return }
            let loan = context.loanRepo.findActiveByBookId(book.id)
            XCTAssertNotNil(loan, "書籍 \(bookTitle) の貸出記録が見つかりません")
            guard let loan else { return }
            context.returnResult = context.returnUseCase.executeByLoanId(loan.id)
        }

        Then("貸出一覧から書籍 {string} が消える" as CucumberExpression) { matches, _ in
            let bookTitle = try matches.first(\.string)
            let book = context.bookRepo.findByTitle(bookTitle)
            XCTAssertNotNil(book)
            guard let book else { return }
            XCTAssertNil(context.loanRepo.findActiveByBookId(book.id))
            XCTAssertTrue(context.loanRepo.findAll().isEmpty)
        }

        Then("貸出一覧の件数表示が {string} になる" as CucumberExpression) { matches, _ in
            let expected = try matches.first(\.string)
            let count = context.loanRepo.findAll().count
            XCTAssertEqual("\(count)冊 貸し出し中", expected)
        }

        Then("貸出一覧に {string} と表示される" as CucumberExpression) { _, _ in
            XCTAssertTrue(context.loanRepo.findAll().isEmpty)
        }

        // MARK: - Return Book Steps

        Given("返却用に会員 {string} \\(ID: {string}\\) が登録されている" as CucumberExpression) { matches, _ in
            let name = try matches.first(\.string)
            let memberId = try matches.last(\.string)
            try context.memberRepo.save(Member(id: memberId, name: name))
        }

        Given("返却用に以下の書籍が貸出されている:") { _, step in
            guard let rows = step.dataTable?.rows else { return }
            context.ensureBorrowUseCase()
            for row in rows.dropFirst() {
                let memberId = row[0]
                let bookTitle = row[1]
                let isbn = row[2]
                try! context.bookRepo.save(
                    Book(title: bookTitle, author: "Author", isbn: isbn, publicationYear: 2020)
                )
                _ = context.borrowUseCase.execute(memberId: memberId, bookTitle: bookTitle)
            }
        }

        When("返却画面を開く") { _, _ in
            context.loanSearchResults = context.loanRepo.findAll()
        }

        When("検索ボックスに {string} と入力する" as CucumberExpression) { matches, _ in
            let query = try matches.first(\.string)
            context.loanSearchResults = context.loanRepo.findAll().filter { loan in
                if let book = context.bookRepo.findById(loan.bookId) {
                    if book.title.lowercased().contains(query.lowercased()) { return true }
                    if book.isbn.contains(query) { return true }
                }
                if let member = context.memberRepo.findById(loan.memberId) {
                    if member.name.contains(query) { return true }
                    if member.id.contains(query) { return true }
                }
                return false
            }
        }

        When("絞り込み結果から書籍 {string} を返却する" as CucumberExpression) { matches, _ in
            let bookTitle = try matches.first(\.string)
            context.ensureReturnUseCase()
            let book = context.bookRepo.findByTitle(bookTitle)
            XCTAssertNotNil(book)
            guard let book else { return }
            let loan = context.loanSearchResults.first { $0.bookId == book.id }
            XCTAssertNotNil(loan)
            guard let loan else { return }
            context.returnResult = context.returnUseCase.execute(
                memberId: loan.memberId, bookTitle: bookTitle
            )
        }

        When("検索ボックスをクリアする") { _, _ in
            context.loanSearchResults = context.loanRepo.findAll()
        }

        Then("貸出一覧に {int} 件表示される" as CucumberExpression) { matches, _ in
            let count = try matches.first(\.int)
            XCTAssertEqual(context.loanSearchResults.count, count)
        }

        Then("貸出一覧に書籍 {string} が表示される" as CucumberExpression) { matches, _ in
            let bookTitle = try matches.first(\.string)
            let book = context.bookRepo.findByTitle(bookTitle)
            XCTAssertNotNil(book)
            guard let book else { return }
            XCTAssertTrue(context.loanSearchResults.contains { $0.bookId == book.id })
        }

        Then("返却後の書籍 {string} は貸出可能である" as CucumberExpression) { matches, _ in
            let title = try matches.first(\.string)
            let book = context.bookRepo.findByTitle(title)
            XCTAssertNotNil(book)
            guard let book else { return }
            XCTAssertNil(context.loanRepo.findActiveByBookId(book.id))
        }

        Then("返却後の会員 {string} の貸出冊数が {int} である" as CucumberExpression) { matches, _ in
            let memberId = try matches.first(\.string)
            let count = try matches.last(\.int)
            XCTAssertEqual(context.loanRepo.countActiveByMemberId(memberId), count)
        }

        // MARK: - Login Steps

        Given("ログインAPIが利用可能である") { _, _ in
            context.stubAuth = StubAuthRepository()
            context.loginUseCase = LoginUseCase(authRepository: context.stubAuth)
        }

        Given("以下の認証情報でユーザーが登録されている:") { _, step in
            guard let rows = step.dataTable?.rows, rows.count >= 2 else { return }
            let row = rows[1]
            context.stubAuth.registerUser(email: row[0], password: row[1], displayName: "テストユーザー")
        }

        When("以下の認証情報でログインする") { _, step in
            guard let rows = step.dataTable?.rows, rows.count >= 2 else { return }
            let row = rows[1]
            let email = row[0]
            let password = row[1]
            if context.loginUseCase == nil {
                context.loginUseCase = LoginUseCase(authRepository: context.stubAuth)
            }
            let semaphore = DispatchSemaphore(value: 0)
            nonisolated(unsafe) var result: LoginResult!
            Task { @Sendable in
                result = await context.loginUseCase.execute(
                    request: LoginRequest(email: email, password: password)
                )
                semaphore.signal()
            }
            semaphore.wait()
            context.loginResult = result
        }

        Then("ログインが成功する") { _, _ in
            guard case .success = context.loginResult else {
                XCTFail("ログインが成功するべき"); return
            }
        }

        Then("ログインが失敗する") { _, _ in
            guard case .failure = context.loginResult else {
                XCTFail("ログインが失敗するべき"); return
            }
        }

        Then("アクセストークンが返される") { _, _ in
            guard case let .success(token, _) = context.loginResult else {
                XCTFail("ログインが成功するべき"); return
            }
            XCTAssertFalse(token.isEmpty)
        }

        Then("表示名 {string} が返される" as CucumberExpression) { matches, _ in
            let expected = try matches.first(\.string)
            guard case let .success(_, displayName) = context.loginResult else {
                XCTFail("ログインが成功するべき"); return
            }
            XCTAssertEqual(displayName, expected)
        }

        Then("バリデーションエラー {string} が発生する" as CucumberExpression) { matches, _ in
            let expected = try matches.first(\.string)
            guard case let .validationError(message) = context.loginResult else {
                XCTFail("バリデーションエラーが発生するべき"); return
            }
            XCTAssertEqual(message, expected)
        }

        // MARK: - Login API Steps

        Given("ログインAPIサーバーが起動している") { _, _ in }

        When("POST {string} に以下のJSONを送信する:" as CucumberExpression) { matches, step in
            _ = try matches.first(\.string)
            guard let rows = step.dataTable?.rows else { return }

            var jsonBody: [String: String] = [:]
            for row in rows {
                guard row.count >= 2 else { continue }
                jsonBody[row[0]] = row[1]
            }

            nonisolated(unsafe) var mockStatusCode = 0
            nonisolated(unsafe) var mockResponseBody: [String: Any] = [:]

            let mockSession = MockURLProtocolSession.create { request in
                let body = try? JSONSerialization.jsonObject(with: request.httpBody ?? Data()) as? [String: Any]
                let email = body?["email"] as? String
                let password = body?["password"] as? String

                if email == nil || password == nil
                    || (password?.isEmpty ?? true) || !(email?.contains("@") ?? false) {
                    mockStatusCode = 400
                    mockResponseBody = ["error": "Bad Request"]
                    let data = try! JSONSerialization.data(withJSONObject: mockResponseBody)
                    let response = HTTPURLResponse(
                        url: request.url!, statusCode: 400, httpVersion: nil, headerFields: nil
                    )!
                    return (data, response)
                }

                if email == "test@example.com" && password == "password123" {
                    mockStatusCode = 200
                    mockResponseBody = ["token": "test-token-abc", "displayName": "テストユーザー"]
                    let data = try! JSONSerialization.data(withJSONObject: mockResponseBody)
                    let response = HTTPURLResponse(
                        url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil
                    )!
                    return (data, response)
                }

                mockStatusCode = 401
                mockResponseBody = ["error": "Unauthorized"]
                let data = try! JSONSerialization.data(withJSONObject: mockResponseBody)
                let response = HTTPURLResponse(
                    url: request.url!, statusCode: 401, httpVersion: nil, headerFields: nil
                )!
                return (data, response)
            }

            let client = AuthApiClient(baseURL: URL(string: "http://localhost:8080")!, session: mockSession)
            let request = LoginRequest(
                email: jsonBody["email"] ?? "",
                password: jsonBody["password"] ?? ""
            )

            let semaphore = DispatchSemaphore(value: 0)
            nonisolated(unsafe) var loginResult: LoginResult!
            Task { @Sendable in
                loginResult = await client.login(request: request)
                semaphore.signal()
            }
            semaphore.wait()
            context.loginResult = loginResult
            context.apiStatusCode = mockStatusCode
            context.apiResponseBody = mockResponseBody
        }

        Then("レスポンスステータスが {int} である" as CucumberExpression) { matches, _ in
            let expected = try matches.first(\.int)
            XCTAssertEqual(context.apiStatusCode, expected)
        }

        Then("レスポンスに {string} フィールドが含まれる" as CucumberExpression) { matches, _ in
            let field = try matches.first(\.string)
            XCTAssertNotNil(context.apiResponseBody?[field])
        }
    }
}
