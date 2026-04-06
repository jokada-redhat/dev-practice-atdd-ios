# iOS BDD テストの制約と回避策

## 対象読者

iOS (Swift/XCTest) で BDD (Gherkin feature ファイル) を用いたテスト開発を行う方。

## 用語

| 用語 | 説明 |
|------|------|
| **XCTest** | Apple 公式のテストフレームワーク。ユニットテスト・UIテスト両方の基盤 |
| **XCUITest** | XCTest の UIテスト機能。テストとアプリが別プロセスで動作する |
| **CucumberSwift** | Gherkin フォーマットの BDD テストを Swift で実行するフレームワーク |
| **PageObject** | 画面ごとに操作をクラス化する設計パターン（例: `LoginPage`, `TopPage`） |

---

## 本プロジェクトのテスト構成

テストを **ユニットテスト層** と **UIテスト層** の2層で構成しています。

| | ユニットテスト (LibrattaTests) | UIテスト (LibrattaUITests) |
|---|---|---|
| フレームワーク | XCTest | XCUITest + CucumberSwift |
| feature ファイル | 仕様ドキュメントとして管理 | CucumberSwift が直接実行 |
| ステップ定義 | XCTestCase のテストメソッド | CucumberSwift のクロージャ |
| 実行対象 | ビジネスロジック | 画面遷移・UI操作 |

```
LibrattaTests/             # ユニットテスト
├── Features/              #   Gherkin feature ファイル（仕様）
└── Steps/                 #   XCTest ステップ定義（実装）

LibrattaUITests/           # UIテスト
├── Features/              #   Gherkin feature ファイル（CucumberSwift が実行）
├── LibrattaUITests.swift  #   CucumberSwift ステップ定義
└── PageObjects/           #   画面操作の抽象化（LoginPage, TopPage 等）
```

---

## 制約 1: ステップ内でのアプリ再起動は後続ステップを壊す

### 前提: XCUITest のプロセス分離

XCUITest では **テストプロセス** と **アプリプロセス** が分離されています。テストコード内の `app` オブジェクトは実際のアプリではなく、プロセス間通信で操作を中継する **プロキシ** です。

```
┌─────────────────┐        ┌─────────────────┐
│ テストプロセス    │  IPC   │ アプリプロセス    │
│                 │◄──────►│                 │
│ app (プロキシ)   │        │ 実際のUI要素     │
└─────────────────┘        └─────────────────┘
```

### 問題

CucumberSwift は各ステップを個別の XCTest テストケースとして実行します。ステップ内で `app.terminate()` + `app.launch()` すると、プロキシが参照していたアプリプロセスが終了し、新しいプロセスが起動します。しかしプロキシの内部状態が更新されず、**後続ステップで UI 要素が一切見つからなくなります**。

```swift
// ✗ これをやると後続ステップが全て失敗する
Given("テストデータをセットアップ") { _, _ in
    app.terminate()                              // ← 古いプロセスを終了
    app.launchArguments.append("--setup-flag")
    app.launch()                                 // ← 新しいプロセスが起動するが
}                                                //    プロキシの内部状態が不整合に

When("次のステップ") { _, _ in
    // ← waitForExistence が常に false を返す
}
```

### なぜ BeforeScenario では問題ないのか

`BeforeScenario` はシナリオの最初のステップの実行コンテキスト内で動作します。プロキシがまだ要素クエリに使われていない初期状態のため、再起動しても内部状態は壊れません。

### 回避策: テストデータの準備は UI 操作で行う

アプリの再起動が必要だと思う場面の多くは、**特定のデータ状態を作りたい**だけです。XCUITest はアプリと別プロセスのため、アプリ内のリポジトリを直接操作できません。しかし、**アプリの UI を操作してデータを変更する**ことはできます。

```swift
// ✓ UI 操作でデータを準備する（貸出上限テストの例）
// DA-0001 は起動時に2冊借りている。上限は3冊。UI で1冊借りれば上限に到達。
Given("会員の貸出冊数を上限に設定する") { matches, _ in
    // PageObjects/ で定義されたヘルパークラスを使って画面操作
    LoginPage(app: app).login(...)
    TopPage(app: app).tapBorrowingCard()
    MemberListPage(app: app).tapMember(memberName)
    BookCatalogPage(app: app).tapBorrowButton(forBook: "坊っちゃん")
    BookCatalogPage(app: app).confirmBorrowDialog()
    // ホームに戻る
    ...
}
```

この方法なら:
- アプリの再起動が不要
- 実際のユーザー操作と同じフローでデータを準備できる
- CucumberSwift のプロキシ問題を回避できる

---

## 制約 2: XCTest にタグフィルタリング機能がない

### 問題

Gherkin の `@smoke` タグでシナリオを分類しても、XCTest にはタグベースのフィルタリング機能がありません。`swift test` コマンドでは「テストクラス」または「テストメソッド」の名前でしかフィルタできません。

> **補足**: Apple の Swift Testing フレームワークにはタグ機能がありますが、XCUITest をサポートしていないため、本プロジェクトでは XCTest で統一しています。

### 回避策: `testSmoke_` 命名規約

ユニットテスト層では、`@smoke` タグ付きシナリオのテストメソッドに `Smoke` プレフィックスを付与し、`swift test --filter` でフィルタリングを実現しています。

```gherkin
@smoke
Scenario: 会員が書籍を借りる
    Given 会員 "山田太郎" (ID: "DA-8821") が登録されている
    ...
```

```swift
final class BorrowingFlowStepTests: XCTestCase {
    // @smoke タグ付き → testSmoke_ プレフィックス
    func testSmoke_会員が書籍を借りる() throws { ... }

    // タグなし → 通常の test プレフィックス
    func test既に借りられている書籍は借りられない() throws { ... }
}
```

```bash
# スモークテストのみ
swift test --filter Smoke

# 全テスト
swift test
```

---

## 制約 3: CucumberSwift の `And` ステップが構文チェックで未解決になる

### CucumberSwift の2つのフェーズ

CucumberSwift のテスト実行には2つのフェーズがあります。

1. **構文チェックフェーズ (`testGherkin`)**: feature ファイルとステップ定義の対応をチェック
2. **シナリオ実行フェーズ**: 実際にシナリオを順番に実行

### 問題

Gherkin の `And` キーワードは、直前の `Given` / `When` / `Then` の代替として使います。

```gherkin
Then 書籍 "吾輩は猫である" のカードが表示されている
And 書籍 "坊っちゃん" のカードが表示されている     ← Then として扱われるべき
```

**シナリオ実行フェーズ** では、`And` を正しく直前のキーワードに解決します。ステップ定義が `Then(...)` であっても `And` 行がマッチし、テストは通ります。

しかし、**`testGherkin` 構文チェック** はこの解決を行いません。`And` 専用のステップ定義がないと "No CucumberSwift expression found" と報告します。

### 影響

- `testGherkin` テストケースが FAILED になる
- **シナリオ実行には影響なし** — 全シナリオは正常に通過する

### なぜ回避策がないのか

`And(...)` で重複登録すると、元の `Then(...)` のマッチングが壊れます。`MatchAll(...)` も同様です。CucumberSwift の既知の設計問題であり、修正の見込みはありません。

- **参照**: [cucumberswift/CucumberSwift#32](https://github.com/cucumberswift/CucumberSwift/issues/32)（2021年から OPEN）

---

## 新しいシナリオを追加するときの手順

### ユニットテスト (LibrattaTests)

1. `Features/` に feature ファイルを追加（`@smoke` タグが必要なら付与）
2. `Steps/` に対応する `*StepTests.swift` を追加
   - `@smoke` 付き → `func testSmoke_シナリオ名()`
   - タグなし → `func testシナリオ名()`
3. `swift test` で全テスト通過を確認

### UIテスト (LibrattaUITests)

1. `Features/` に feature ファイルを追加
2. `LibrattaUITests.swift` にステップ定義を追加（`Given` / `When` / `Then`）
3. 必要に応じて `PageObjects/` にページオブジェクトを追加
4. `xcodebuild test -scheme LibrattaUITests` で全シナリオ通過を確認
5. **注意**: `And` ステップの `testGherkin` エラーは無視してよい（制約 3 参照）
