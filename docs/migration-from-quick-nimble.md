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
// BorrowingFlowSteps.swift — 実装（Swift / CucumberSwift）
extension Cucumber {
    func registerBorrowingFlowSteps(context: ScenarioContext) {
        When("会員 {string} が書籍 {string} を借りる" as CucumberExpression) { matches, _ in
            let memberId = try matches.first(\.string)
            let bookTitle = try matches.last(\.string)
            context.ensureBorrowUseCase()
            context.borrowResult = context.borrowUseCase.execute(
                memberId: memberId, bookTitle: bookTitle
            )
        }
    }
}
```

> **補足**: 両層とも CucumberSwift が feature ファイルの各ステップを自動マッチングして実行します。ステップ定義は `extension Cucumber` のインスタンスメソッドとして feature ごとにファイル分割しています。

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

**CucumberSwift が feature ファイルを直接実行** します。ステップ定義は `extension Cucumber` のインスタンスメソッドとして feature ごとにファイル分割しています。

```
LibrattaTests/
├── Features/              # Gherkin 仕様（CucumberSwift が実行）
│   └── borrowing_flow.feature
├── CucumberRunner/
│   ├── LibrattaTestRunner.swift   # setupSteps() — 各 Steps を register
│   ├── ScenarioContext.swift      # シナリオ間の状態管理
│   └── Steps/                     # feature ごとのステップ定義
│       ├── SharedSteps.swift
│       └── BorrowingFlowSteps.swift
└── Support/
    └── MockURLProtocolSession.swift
```

```swift
// BorrowingFlowSteps.swift
extension Cucumber {
    func registerBorrowingFlowSteps(context: ScenarioContext) {
        When("会員 {string} が書籍 {string} を借りる" as CucumberExpression) { matches, _ in
            let memberId = try matches.first(\.string)
            let bookTitle = try matches.last(\.string)
            context.ensureBorrowUseCase()
            context.borrowResult = context.borrowUseCase.execute(
                memberId: memberId, bookTitle: bookTitle
            )
        }
    }
}
```

Quick/Nimble との違い:
- `describe` / `it` ではなく CucumberSwift の `Given` / `When` / `Then` クロージャ
- `expect(...).to(...)` ではなく `XCTAssertEqual` / `XCTAssertTrue`
- feature ファイルの各ステップが CucumberSwift により自動マッチング・実行される

### UIテスト層 (LibrattaUITests)

こちらも **CucumberSwift が feature ファイルを直接実行** します。PageObject パターンで画面操作を抽象化しています。

```
LibrattaUITests/
├── Features/              # Gherkin 仕様（CucumberSwift が実行）
│   └── borrowing_flow_ui.feature
├── LibrattaUITests.swift  # setupSteps() — 各 Steps を register
├── Steps/                 # feature ごとのステップ定義
│   ├── LoginUISteps.swift
│   └── BookCatalogUISteps.swift
└── PageObjects/           # 画面操作のヘルパー
    ├── LoginPage.swift
    └── BookCatalogPage.swift
```

```swift
// BookCatalogUISteps.swift
extension Cucumber {
    func registerBookCatalogUISteps(app: XCUIApplication) {
        Given("書籍カタログ画面が会員 {string} で表示されている" as CucumberExpression) { matches, _ in
            let memberName = try matches.first(\.string)
            LoginPage(app: app).login(email: "librarian@example.com", password: "password")
            TopPage(app: app).tapBorrowingCard()
            MemberListPage(app: app).tapMember(memberName)
            BookCatalogPage(app: app).verifyDisplayed()
        }
    }
}
```

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
- [ ] 両層とも CucumberSwift が feature ファイルを自動実行すること

### 実践の準備

- [ ] UIテストの PageObject パターン（`PageObjects/` ディレクトリ）を確認した
- [ ] [ios-bdd-constraints.md](./ios-bdd-constraints.md) の制約（CucumberExpression、`@` 記号、multi-capture）を把握した
- [ ] [atdd-guide.md](./atdd-guide.md) の ATDD ワークフローを確認した
- [ ] 実際のプロジェクトコード（`LibrattaTests/CucumberRunner/Steps/` と `LibrattaUITests/Steps/`）を読んだ
