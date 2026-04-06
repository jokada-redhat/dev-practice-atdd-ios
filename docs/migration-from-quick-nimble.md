# Quick/Nimble から Gherkin BDD への移行ガイド

## 対象読者

Quick/Nimble を使った BDD テスト経験があり、本プロジェクトの Gherkin ベースのテストに初めて触れる方。

---

## Quick/Nimble と Gherkin: 何が違うのか

### 共通点

どちらも **振る舞い (Behavior) を記述してテストする** BDD フレームワークです。

- テストが仕様として読める
- 前提条件 → 操作 → 期待結果 の構造
- ネストしたコンテキストでテストを整理

### 根本的な違い: 仕様と実装の分離

Quick/Nimble では **仕様と実装が同じ Swift ファイル** に書かれます。

```swift
// Quick/Nimble: 仕様と実装が一体
describe("貸出フロー") {
    context("会員が書籍を借りるとき") {
        beforeEach {
            memberRepo.save(Member(id: "DA-8821", name: "山田太郎"))
            bookRepo.save(Book(title: "吾輩は猫である", ...))
        }
        it("書籍が貸出中になる") {
            let result = borrowUseCase.execute(memberId: "DA-8821", bookTitle: "吾輩は猫である")
            expect(result).to(beSuccess())
            expect(loanRepo.findActiveByBookId(book.id)).toNot(beNil())
        }
    }
}
```

Gherkin では **仕様 (feature ファイル) と実装 (ステップ定義) が別ファイル** です。

```gherkin
# borrowing_flow.feature — 仕様（自然言語）
Scenario: 会員が書籍を借りる
    Given 会員 "山田太郎" (ID: "DA-8821") が登録されている
    And 書籍 "吾輩は猫である" が登録されている
    When 会員 "DA-8821" が書籍 "吾輩は猫である" を借りる
    Then 書籍 "吾輩は猫である" は貸出中である
```

```swift
// BorrowingFlowStepTests.swift — 実装（Swift）
func testSmoke_会員が書籍を借りる() throws {
    try setupMember("山田太郎", id: "DA-8821")
    try setupBook("吾輩は猫である")

    let result = borrowUseCase.execute(memberId: "DA-8821", bookTitle: "吾輩は猫である")

    guard case .success = result else { XCTFail("貸出が成功するべき"); return }
    let book = bookRepo.findByTitle("吾輩は猫である")!
    XCTAssertNotNil(loanRepo.findActiveByBookId(book.id))
}
```

> **重要**: feature ファイルの各 Given/When/Then 行とテストコードの対応は、テスト層によって異なります。
>
> - **ユニットテスト層**: feature ファイルの各ステップは個別に実装されません。テストメソッド全体で1つのシナリオを実装します。
> - **UIテスト層**: feature ファイルの各ステップが個別のステップ定義クロージャに対応し、CucumberSwift が自動実行します。
>
> 詳しくは後述の各層のセクションを参照してください。

### なぜ分離するのか

- **feature ファイルは非エンジニアも読める**: プロダクトオーナーや QA が仕様を確認・レビューできる
- **プラットフォーム間で仕様を共有できる**: 本プロジェクトでは iOS と Android で同じ feature ファイルを使用
- **仕様の変更と実装の変更を分離できる**: feature ファイルの変更はビジネス要件の変更、ステップ定義の変更は技術的な変更

---

## 概念の対応表

| Quick/Nimble | Gherkin / 本プロジェクト | 備考 |
|---|---|---|
| `describe("...")` | `Feature: ...` | テスト対象の機能 |
| `context("...")` | `Scenario: ...` | 特定の条件下でのテスト |
| `beforeEach { }` | `Given ...` | 前提条件のセットアップ（※1） |
| (操作の呼び出し) | `When ...` | テスト対象のアクション |
| `it("...") { expect(...) }` | `Then ...` | 期待結果のアサーション |
| `beforeSuite { }` | `BeforeScenario { }` | テスト全体 / シナリオ前の初期化 |
| `Nimble` マッチャ | `XCTAssert*` | アサーション方法 |
| `.swift` ファイル1つ | `.feature` + `.swift` の2ファイル | 仕様と実装の分離 |

> **※1**: Quick/Nimble の `beforeEach` は**全テストで自動実行**されますが、Gherkin の `Given` は **feature ファイルで明示的に記述した場合のみ実行**されます。全シナリオ共通の初期化は `BeforeScenario` を使います。

---

## 本プロジェクトのテスト層

### ユニットテスト層 (LibrattaTests)

Quick/Nimble に最も近い形です。feature ファイルは **仕様ドキュメント** として管理し、テスト実装は **XCTestCase のメソッド** で行います。

```
LibrattaTests/
├── Features/              # Gherkin 仕様（読むもの。自動実行されない）
│   └── borrowing_flow.feature
└── Steps/                 # XCTest 実装（動かすもの）
    └── BorrowingFlowStepTests.swift
```

feature ファイルの Given/When/Then はテストメソッド内で **一連のロジック** として実装します。ステップごとに分割はしません。

```swift
// feature ファイルの1シナリオ = テストメソッド1つ
func testSmoke_会員が書籍を借りる() throws {
    try setupMember("山田太郎", id: "DA-8821")     // ← Given に対応
    try setupBook("The Infinite Library")

    let result = borrowUseCase.execute(             // ← When に対応
        memberId: "DA-8821",
        bookTitle: "The Infinite Library"
    )

    guard case .success = result else {             // ← Then に対応
        XCTFail("貸出が成功するべき"); return
    }
    let book = bookRepo.findByTitle("The Infinite Library")!
    XCTAssertNotNil(loanRepo.findActiveByBookId(book.id))
    XCTAssertEqual(loanRepo.countActiveByMemberId("DA-8821"), 1)
}
```

Quick/Nimble との違い:
- `describe` / `it` ではなく `XCTestCase` のメソッド
- `expect(...).to(...)` ではなく `XCTAssertEqual` / `XCTAssertTrue`
- feature ファイルは自動実行されない（仕様ドキュメントとして参照）

### UIテスト層 (LibrattaUITests)

こちらは **CucumberSwift が feature ファイルを直接実行** します。Quick/Nimble にはない仕組みです。

```
LibrattaUITests/
├── Features/              # Gherkin 仕様（CucumberSwift が実行）
│   └── borrowing_flow_ui.feature
├── LibrattaUITests.swift  # ステップ定義（Given/When/Then クロージャ）
└── PageObjects/           # 画面操作のヘルパー
    ├── LoginPage.swift
    └── BookCatalogPage.swift
```

feature ファイルの各行が **個別のステップ定義クロージャ** に対応します。

```swift
// feature ファイルの各ステップに対応するクロージャを登録
Given("トップ画面が表示されている") { _, _ in
    LoginPage(app: app).login(email: "librarian@example.com", password: "password")
    TopPage(app: app).verifyDisplayed()
}

When("貸し出しカードをタップする") { _, _ in
    TopPage(app: app).tapBorrowingCard()
}

Then("会員一覧画面が表示される") { _, _ in
    MemberListPage(app: app).verifyDisplayed()
}
```

> **`And` ステップについて**: feature ファイルで `And` を使うと、直前の `Given`/`When`/`Then` として解決されます。`And` 専用のステップ定義は不要です。ただし、CucumberSwift の構文チェック (`testGherkin`) では未解決エラーが報告されます（シナリオ実行には影響なし）。詳細は [ios-bdd-constraints.md](./ios-bdd-constraints.md) の「制約 3」を参照。

---

## Quick/Nimble 経験者が注意すべきポイント

### 1. ステップは再利用される

Quick/Nimble では各 `it` ブロックが独立しています。Gherkin では **同じステップ定義を複数のシナリオで共有** します。

```gherkin
# シナリオ A
Scenario: 書籍カタログを表示
    Given 書籍カタログ画面が会員 "山田太郎" で表示されている
    Then 書籍 "吾輩は猫である" のカードが表示されている

# シナリオ B（同じ Given を再利用）
Scenario: フィルタで絞り込み
    Given 書籍カタログ画面が会員 "山田太郎" で表示されている
    When "Available" フィルタボタンをタップする
    Then ...
```

ステップ定義を書くときは「このシナリオだけ」ではなく「他のシナリオからも呼ばれる」前提で設計してください。

### 2. アサーションは `Nimble` ではなく `XCTAssert`

```swift
// Quick/Nimble
expect(result).to(equal(.success))
expect(books).to(haveCount(3))
expect(error).to(beNil())

// 本プロジェクト（XCTest）
XCTAssertEqual(result, .success)
XCTAssertEqual(books.count, 3)
XCTAssertNil(error)
```

### 3. `context` のネストは Gherkin にない

Quick/Nimble では `context` をネストして条件を細分化できますが、Gherkin ではフラットな `Scenario` の並びです。条件の違いは `Given` ステップで表現します。

```swift
// Quick/Nimble: ネストで条件分岐
describe("貸出") {
    context("上限に達していない場合") {
        it("借りられる") { ... }
    }
    context("上限に達している場合") {
        it("エラーになる") { ... }
    }
}
```

```gherkin
# Gherkin: フラットなシナリオで条件分岐
Scenario: 会員が書籍を借りる
    Given 会員 "山田太郎" が登録されている
    ...

Scenario: 貸出上限に達している場合は借りられない
    Given 会員 "山田太郎" の貸出冊数を上限に設定する
    ...
```

---

## 移行チェックリスト

本プロジェクトで作業を始める前に確認しておくとスムーズです。

### 概念の理解

- [ ] Gherkin の基本構文（`Feature` / `Scenario` / `Given` / `When` / `Then` / `And`）
- [ ] feature ファイルが「仕様」、ステップ定義が「実装」であること
- [ ] ユニットテスト層（XCTest 直接）と UIテスト層（CucumberSwift）の違い

### 実践の準備

- [ ] ユニットテストの `@smoke` タグ対応は `testSmoke_` プレフィックスで行う
- [ ] UIテストの PageObject パターン（`PageObjects/` ディレクトリ）を確認した
- [ ] [ios-bdd-constraints.md](./ios-bdd-constraints.md) の制約（特にアプリ再起動と `And` ステップ）を把握した
- [ ] [atdd-guide.md](./atdd-guide.md) の ATDD ワークフローを確認した
- [ ] 実際のプロジェクトコード（`LibrattaTests/Steps/*.swift` と `LibrattaUITests/LibrattaUITests.swift`）を読んだ
