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

テストを **ユニットテスト層** と **UIテスト層** の2層で構成しています。両層とも CucumberSwift で feature ファイルを直接実行します。

| | ユニットテスト (LibrattaTests) | UIテスト (LibrattaUITests) |
|---|---|---|
| フレームワーク | XCTest + CucumberSwift | XCUITest + CucumberSwift |
| feature ファイル | CucumberSwift が直接実行 | CucumberSwift が直接実行 |
| ステップ定義 | `extension Cucumber` のインスタンスメソッド | `extension Cucumber` のインスタンスメソッド |
| 実行対象 | ビジネスロジック | 画面遷移・UI操作 |

```
LibrattaTests/             # ユニットテスト
├── Features/              #   Gherkin feature ファイル（CucumberSwift が実行）
├── CucumberRunner/
│   ├── LibrattaTestRunner.swift   # setupSteps() — 各 Steps を register 呼び出し
│   ├── ScenarioContext.swift      # シナリオ間の状態管理
│   └── Steps/                     # feature ごとのステップ定義
│       ├── SharedSteps.swift
│       ├── SessionSteps.swift
│       ├── MemberManagementSteps.swift
│       ├── BookManagementSteps.swift
│       ├── BookCatalogSteps.swift
│       ├── BorrowingFlowSteps.swift
│       ├── ReturnFromListSteps.swift
│       ├── ReturnBookSteps.swift
│       ├── LoginSteps.swift
│       └── LoginApiSteps.swift
└── Support/
    └── MockURLProtocolSession.swift

LibrattaUITests/           # UIテスト
├── Features/              #   Gherkin feature ファイル（CucumberSwift が実行）
├── LibrattaUITests.swift  #   setupSteps() — 各 Steps を register 呼び出し
├── Steps/                 #   feature ごとのステップ定義
│   ├── LoginUISteps.swift
│   ├── NavigationUISteps.swift
│   ├── BookCatalogUISteps.swift
│   └── BorrowingFlowUISteps.swift
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

## 制約 2: `{string}` パラメータには `as CucumberExpression` が必要

### 問題

CucumberSwift のステップ定義で `{string}` を使うと、デフォルトでは deprecated な正規表現オーバーロードが選択されます。`{string}` は NSRegularExpression で無効なパターンのため、**ステップが feature ファイルとマッチせず、テストが実行されない（偽陽性）** 状態になります。

```swift
// ✗ {string} が無効な正規表現として扱われ、ステップが一切マッチしない
Then("書籍 {string} のカードが表示されている") { matches, _ in
    let title = matches[1]  // 実行されない
}
```

### 回避策: `as CucumberExpression` を付与する

パターン文字列に `as CucumberExpression` を付けると、Cucumber Expression として正しく解析されます。コールバックの型が `[String]` から `CucumberSwiftExpressions.Match` に変わるため、値の取得方法も変わります。

```swift
import CucumberSwiftExpressions

// ✓ CucumberExpression として正しくマッチ
Then("書籍 {string} のカードが表示されている" as CucumberExpression) { matches, _ in
    let title = try matches.first(\.string)
    BookCatalogPage(app: app).verifyBookExists(title)
}

// 2つの {string} パラメータがある場合
When("ユーザー {string} がパスワード {string} でログインする" as CucumberExpression) { matches, _ in
    let user = try matches.first(\.string)
    let password = try matches.last(\.string)
}
```

パラメータなしのステップには `as CucumberExpression` は不要です。

---

## 制約 3: multi-capture CucumberExpression は `setupSteps()` コンテキスト内でのみコンパイル可能

### 問題

`{string}` が2つ以上ある CucumberExpression は、`enum` や `struct` の `static` メソッドから呼び出すとコンパイルエラーになります。Swift コンパイラが `Regex<Output>` のジェネリックパラメータを推論できないためです。

```swift
// ✗ static メソッドからはコンパイルエラー
enum MySteps {
    static func register() {
        Given("会員 {string} が書籍 {string} を借りる" as CucumberExpression) { matches, _ in
            // error: cannot convert value of type 'CucumberExpression' to expected argument type 'Regex<Output>'
        }
    }
}
```

### 回避策: `extension Cucumber` のインスタンスメソッドで分割する

`setupSteps()` 内では `self` が `Cucumber` インスタンスのため、正しいオーバーロードが選択されます。ステップ定義を `extension Cucumber` のインスタンスメソッドに分割すれば、同じコンテキストが維持されます。

```swift
// ✓ extension Cucumber のインスタンスメソッドなら OK
extension Cucumber {
    func registerBorrowingFlowSteps(context: ScenarioContext) {
        Given("会員 {string} が書籍 {string} を借りる" as CucumberExpression) { matches, _ in
            let memberId = try matches.first(\.string)
            let bookTitle = try matches.last(\.string)
            // ...
        }
    }
}

// setupSteps() から呼び出す
public func setupSteps() {
    let context = ScenarioContext()
    registerBorrowingFlowSteps(context: context)
}
```

### 3パラメータ以上の場合

`matches.first` / `matches.last` では中間要素にアクセスできないため、3パラメータ以上のステップは DataTable に分割してください。

```gherkin
# ✗ 3パラメータ — 中間値にアクセスできない
Given 会員 "DA-8821" が書籍 "The Infinite Library" (ISBN: "978-1234567890") を借りている

# ✓ DataTable で渡す
Given 返却用に以下の書籍が貸出されている:
  | memberId | title                | isbn           |
  | DA-8821  | The Infinite Library | 978-1234567890 |
```

---

## 制約 4: ステップテキスト内の `@` がタグとして誤認される

### 問題

CucumberSwift の Lexer は `@` を常にタグマーカーとして解釈します。ステップテキスト内に `@` が含まれると、その部分がタグとして切り出され、ステップマッチから欠落します。

```gherkin
# ✗ "librarian@example.com" の @example がタグとして誤認される
When メールアドレス "librarian@example.com" とパスワード "password" でログインする
```

- `\@` エスケープは機能しません（Lexer のエスケープ処理は `\#` のみ対応）
- `testGherkin` で "unexpected end of file" エラーが発生
- ステップマッチが `"librarian.com"` に壊れ、テストが意図通り動作しない

### 回避策: DataTable で `@` を含む値を渡す

Lexer のテーブルセル処理 (`readCell()`) は `@` を特別扱いしないため、DataTable 内では `@` がそのまま文字列として扱われます。

```gherkin
# ✓ DataTable 内の @ はタグとして解釈されない
When 以下の認証情報でログインする
    | email                 | password |
    | librarian@example.com | password |
```

```swift
When("以下の認証情報でログインする") { _, step in
    let row = step.dataTable!.rows[1]
    LoginPage(app: app).login(email: row[0], password: row[1])
}
```

---

## 新しいシナリオを追加するときの手順

### ユニットテスト (LibrattaTests)

1. `Features/` に feature ファイルを追加
2. `CucumberRunner/Steps/` に対応する `*Steps.swift` を追加
   - `extension Cucumber` のインスタンスメソッド `register*Steps(context:)` として定義
   - `{string}` パラメータを使うステップは `as CucumberExpression` を付ける（制約 2 参照）
   - 3パラメータ以上は DataTable に分割する（制約 3 参照）
3. `LibrattaTestRunner.swift` の `setupSteps()` に `register*Steps(context:)` 呼び出しを追加
4. `swift test` または `xcodebuild test -scheme LibrattaTests` で全テスト通過を確認

### UIテスト (LibrattaUITests)

1. `Features/` に feature ファイルを追加
2. `Steps/` に対応する `*UISteps.swift` を追加
   - `extension Cucumber` のインスタンスメソッド `register*UISteps(app:)` として定義
   - `{string}` パラメータを使うステップは `as CucumberExpression` を付ける（制約 2 参照）
3. 必要に応じて `PageObjects/` にページオブジェクトを追加
4. `LibrattaUITests.swift` の `setupSteps()` に `register*UISteps(app:)` 呼び出しを追加
5. ステップテキストに `@` を含めない — DataTable で渡す（制約 4 参照）
6. `xcodebuild test -scheme LibrattaUITests` で全シナリオ通過を確認（`testGherkin` 含む）
