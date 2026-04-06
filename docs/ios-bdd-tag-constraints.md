# iOS BDD テストにおける @smoke タグの制約と回避策

## 対象読者

Kotlin/Java + Cucumber でのBDD開発経験があり、iOS (Swift/XCTest) での開発は初めての方。

---

## 背景: Android での @smoke タグ

Android (Kotlin) では、Cucumber JVM がテストランナーとして動作し、feature ファイルの `@smoke` タグを直接認識できます。

```gherkin
# Android: feature ファイル
@smoke
Scenario: 会員が書籍を借りる
    Given ...
```

```bash
# Android: @smoke タグのテストだけ CI で実行
./gradlew test -Dcucumber.filter.tags="@smoke"
```

Cucumber がタグを解釈し、該当するシナリオだけを実行してくれます。

---

## iOS の制約: なぜ同じことができないのか

### 1. iOS には Cucumber ランナーがない

iOS/Swift には Cucumber JVM に相当する公式テストランナーが存在しません。CucumberSwift というライブラリはありますが、成熟度や Swift 6 対応の面で Android の Cucumber JVM ほど安定していません。

本プロジェクトでは、feature ファイル (.feature) を **仕様ドキュメント** として管理し、テスト実装は **XCTest の手書きメソッド** で行っています。

```
LibrattaTests/
├── Features/           # Gherkin feature ファイル（仕様）
│   ├── borrowing_flow.feature
│   └── ...
└── Steps/              # XCTest ステップ定義（実装）
    ├── BorrowingFlowStepTests.swift
    └── ...
```

### 2. XCTest にタグ機能がない

XCTest (Apple の標準テストフレームワーク) にはタグやカテゴリの概念がありません。テストの実行単位は「テストクラス」または「テストメソッド」であり、Cucumber のようにタグで横断的にフィルタリングすることはできません。

### 3. Swift Testing のタグ機能は UITest に使えない

Apple が新しく導入した Swift Testing フレームワークには `@Test(.tags(.smoke))` というタグ機能があります。

```swift
// Swift Testing のタグ機能
@Test(.tags(.smoke))
func 会員が書籍を借りる() { ... }
```

```bash
# Swift Testing: タグでフィルタ
swift test --filter tag:smoke
```

しかし、**Swift Testing は XCUITest (UIテスト) をサポートしていません。** XCUITest は `XCTestCase` のサブクラスでないとアプリのライフサイクル管理が動作しないため、Swift Testing の struct ベースの仕組みとは互換性がありません。

| | XCTest | Swift Testing |
|---|---|---|
| ユニットテスト | OK | OK |
| UIテスト (XCUITest) | OK | **不可** |
| タグフィルタリング | **不可** | OK |

Swift Testing に移行するとユニットテストのタグは解決しますが、UIテストとの統一性が失われます。テスト基盤が2種類に分かれることで複雑性が増すため、本プロジェクトでは **XCTest で統一** する方針としました。

---

## 回避策: `testSmoke_` 命名規約

feature ファイルの `@smoke` タグに対応するテストメソッドに `Smoke` プレフィックスを付けることで、`swift test --filter` によるフィルタリングを実現しています。

### feature ファイル

```gherkin
@smoke
Scenario: 会員が書籍を借りる
    Given 会員 "山田太郎" (ID: "DA-8821") が登録されている
    And 書籍 "The Infinite Library" が登録されている
    When 会員 "DA-8821" が書籍 "The Infinite Library" を借りる
    Then 書籍 "The Infinite Library" は貸出中である
```

### XCTest ステップ定義

```swift
final class BorrowingFlowStepTests: XCTestCase {
    // @smoke タグ付きシナリオ → testSmoke_ プレフィックス
    func testSmoke_会員が書籍を借りる() throws {
        // Given
        let member = Member(id: "DA-8821", name: "山田太郎")
        try memberRepo.save(member)
        // ...
    }

    // タグなしシナリオ → 通常の test プレフィックス
    func test既に借りられている書籍は借りられない() throws {
        // ...
    }
}
```

### CI での実行

```bash
# スモークテストのみ（高速フィードバック）
swift test --filter Smoke

# 全テスト
swift test
```

---

## Android と iOS の対応表

| 概念 | Android (Kotlin) | iOS (Swift) |
|------|-----------------|-------------|
| テストフレームワーク | Cucumber JVM + JUnit | XCTest |
| feature ファイル | Cucumber が直接実行 | 仕様ドキュメント（手動でテストに反映） |
| ステップ定義 | `@Given`/`@When`/`@Then` アノテーション | XCTestCase のテストメソッド |
| `@smoke` タグ | Cucumber が認識・フィルタ | `testSmoke_` 命名規約 + `--filter` |
| UIテスト | Cucumber + Espresso | XCUITest (XCTestCase) |
| CI でのタグ実行 | `-Dcucumber.filter.tags="@smoke"` | `swift test --filter Smoke` |

---

## CucumberSwift (UIテスト) の既知の制約

UIテスト層では CucumberSwift を使用して feature ファイルを直接実行していますが、以下の制約があります。

### 1. `And` / `But` ステップが testGherkin で未解決になる

CucumberSwift の `testGherkin` バリデータは、`And` を直前のキーワード (`Then` / `When`) に解決しません。`Then(...)` で定義したステップに `And` 行がマッチせず、"No CucumberSwift expression found" と報告されます。

- **シナリオ実行には影響なし** — 実行時は正しく解決される
- **参照**: [cucumberswift/CucumberSwift#32](https://github.com/cucumberswift/CucumberSwift/issues/32)（2021年から OPEN）
- `And(...)` や `MatchAll(...)` で重複登録する回避策は、`Then(...)` のマッチングを壊すため使用不可

### 2. ステップ内でのアプリ再起動は後続ステップを壊す

CucumberSwift は各ステップを個別の XCTest テストケースとして実行します。ステップ内で `app.terminate()` + `app.launch()` すると、XCUIApplication プロキシの内部状態が壊れ、**後続ステップで UI 要素が一切見つからなくなります**。

```swift
// ✗ これをやると後続ステップが全て失敗する
Given("テストデータをセットアップ") { _, _ in
    app.terminate()
    app.launchArguments.append("--setup-flag")
    app.launch()
}
```

`BeforeScenario` での再起動は問題ありません（プロキシが未使用の初期状態で実行されるため）。

**回避策**: テストデータの準備は、アプリ再起動ではなく **UI 操作**で行う。

```swift
// ✓ UI 操作でデータを準備する
Given("会員の貸出冊数を上限に設定する") { matches, _ in
    // ログイン → 書籍カタログ → 貸出 → ホームに戻る
    LoginPage(app: app).login(...)
    TopPage(app: app).tapBorrowingCard()
    MemberListPage(app: app).tapMember(memberName)
    BookCatalogPage(app: app).tapBorrowButton(forBook: "坊っちゃん")
    BookCatalogPage(app: app).confirmBorrowDialog()
    // ...
}
```

---

## 新しいシナリオを追加するときの手順

1. feature ファイルにシナリオを追加（`@smoke` タグが必要なら付与）
2. 対応する `*StepTests.swift` にテストメソッドを追加
   - `@smoke` 付き → `func testSmoke_シナリオ名()`
   - タグなし → `func testシナリオ名()`
3. `swift test` で全テスト通過を確認
4. `swift test --filter Smoke` でスモークテストが正しくフィルタされることを確認
