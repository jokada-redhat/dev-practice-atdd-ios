# ATDD（受け入れテスト駆動開発）ガイド

## 目次

1. [ATDD とは何か](#1-atdd-とは何か)
2. [TDD・BDD との違い](#2-tddbdd-との違い)
3. [ATDD のサイクル](#3-atdd-のサイクル)
4. [Gherkin の書き方](#4-gherkin-の書き方)
5. [良いシナリオを書くためのポイント](#5-良いシナリオを書くためのポイント)
6. [本プロジェクトでの実践](#6-本プロジェクトでの実践)
7. [よくある質問](#7-よくある質問)

---

## 1. ATDD とは何か

**ATDD（Acceptance Test Driven Development）** は、機能の実装を始める前に「受け入れ条件」を自動テストとして定義し、そのテストが通ることをゴールに開発を進める手法です。

核となる考え方はシンプルです:

> **「完成」の定義を先に決めてから作り始める。**

受け入れ条件はビジネス要件をそのまま反映したテストなので、開発者・テスター・ビジネス担当者が「何を作るか」について共通認識を持てます。

### ATDD がもたらすもの

- **認識のずれの防止**: 作る前に「何が正しい動作か」を全員で合意する
- **生きたドキュメント**: テストがそのまま仕様書になる。コードと乖離しない
- **リグレッション防止**: 既存機能が壊れたらすぐ気付ける
- **スコープの明確化**: 「このシナリオが通れば完了」というゴールが明確

## 2. TDD・BDD との違い

| 観点 | TDD | BDD | ATDD |
|------|-----|-----|------|
| **テストの粒度** | ユニット（関数・クラス） | 振る舞い（機能） | 受け入れ条件（ユーザー視点） |
| **誰が書くか** | 開発者 | 開発者 | 開発者 + ビジネス担当者 |
| **言語** | プログラミング言語 | 自然言語に近い DSL | 自然言語（Gherkin） |
| **目的** | 設計の改善 | 振る舞いの定義 | 要件の合意と検証 |
| **スコープ** | 内部実装 | 機能単位 | ビジネス要件単位 |

これらは対立する概念ではなく **補完関係** にあります。ATDD で受け入れテストを書き、その中で TDD を使って個々のクラスを実装し、BDD の記法（Given-When-Then）でシナリオを記述する、という組み合わせが一般的です。

## 3. ATDD のサイクル

ATDD は以下のサイクルで進みます:

```
1. 受け入れ条件を定義（feature ファイル作成）
   ↓
2. テストを実行 → 失敗（RED）
   ↓
3. ステップ定義を実装
   ↓
4. プロダクションコードを実装 → テスト成功（GREEN）
   ↓
5. リファクタリング
   ↓
（次の機能へ → 1 に戻る）
```

### ポイント: テストと実装を分けてコミットする

ATDD のプロセスを明確にするため、テストの追加と実装を別のコミットにします:

```
test: 貸出上限の受け入れテストを追加    ← まずテスト（RED）
impl: BorrowBookUseCase に貸出上限チェックを追加  ← 次に実装（GREEN）
refactor: 貸出冊数の判定ロジックを抽出   ← 最後にリファクタ
```

これにより、git の履歴から「何を作ろうとしたか（テスト）」と「どう作ったか（実装）」が分離されて読みやすくなります。

## 4. Gherkin の書き方

ATDD では **Gherkin** という記法でシナリオを記述します。`.feature` ファイルに書きます。

### 基本構造

```gherkin
Feature: 機能の名前
  機能の説明文（任意）

  Scenario: シナリオの名前
    Given 前提条件（テストの初期状態を用意する）
    When  操作（ユーザーが行うアクション）
    Then  期待結果（どうなるべきか）
```

### Given-When-Then の役割

| キーワード | 役割 | 例 |
|-----------|------|-----|
| **Given** | 前提条件のセットアップ | `Given 会員 "山田太郎" (ID: "DA-8821") が登録されている` |
| **When** | ユーザーのアクション | `When 会員 "DA-8821" が書籍 "Dune" を借りる` |
| **Then** | 期待する結果の検証 | `Then 会員 "DA-8821" の貸出冊数が 1 になる` |
| **And** | 直前のキーワードの続き | `And 貸出記録が作成される` |

### 実際の例

本プロジェクトの `borrowing_flow.feature` から:

```gherkin
Feature: 貸し出しフロー
  会員が書籍を借りることができる

  Scenario: 会員が書籍を借りる
    Given 会員 "山田太郎" (ID: "DA-8821") が登録されている
    And 書籍 "The Infinite Library" が登録されている
    When 会員 "DA-8821" が書籍 "The Infinite Library" を借りる
    Then 書籍 "The Infinite Library" は貸出中である
    And 会員 "DA-8821" の貸出冊数が 1 になる
    And 貸出記録が作成される
```

### その他の Gherkin 機能

#### Background（共通の前提条件）

全シナリオで共通の Given をまとめられます:

```gherkin
Background:
  Given 会員 "山田太郎" (ID: "DA-8821") が登録されている
  And 書籍 "The Infinite Library" が登録されている

Scenario: 書籍を借りる
  When 会員 "DA-8821" が書籍 "The Infinite Library" を借りる
  Then ...

Scenario: 書籍を返却する
  Given 会員 "DA-8821" が書籍 "The Infinite Library" を既に借りている
  When 会員 "DA-8821" が書籍 "The Infinite Library" を返却する
  Then ...
```

#### DataTable（表形式のデータ）

複数のデータをまとめて渡せます:

```gherkin
Scenario: 登録済みの書籍が一覧表示される
  Given 書籍管理に以下の書籍が登録されている:
    | title               | author        | isbn           | year |
    | The Infinite Library | Jorge Borges  | 978-1234567890 | 2020 |
    | Foundation           | Isaac Asimov  | 978-0553293357 | 1951 |
  When 書籍一覧を表示する
  Then 書籍一覧に 2 件表示される
```

#### タグ（テストのグループ化）

シナリオにタグを付けて、実行対象を絞り込めます:

```gherkin
@smoke
Scenario: 会員が書籍を借りる
  ...
```

## 5. 良いシナリオを書くためのポイント

### 5.1 ビジネス言語で書く

```gherkin
# 悪い例（実装の詳細が漏れている）
Given データベースに memberId="DA-8821" のレコードが INSERT されている
When POST /api/loans に {"memberId": "DA-8821", "bookId": "123"} を送信する

# 良い例（ビジネス要件を反映）
Given 会員 "山田太郎" (ID: "DA-8821") が登録されている
When 会員 "DA-8821" が書籍 "The Infinite Library" を借りる
```

### 5.2 Given はセットアップ、Then は検証

Given と Then で同じ言葉を使うと紛らわしくなります。セットアップと検証で表現を使い分けます:

```gherkin
# Given（セットアップ）: 「登録されている」= この書籍が存在する
Given 書籍 "The Infinite Library" が登録されている

# Then（検証）: 「貸出可能である」= 貸出可能な状態になった
Then 書籍 "The Infinite Library" は貸出可能である
```

### 5.3 一度テストした振る舞いは Given で宣言的に使う

「書籍を借りる」シナリオが既にある場合、他のシナリオでは借りる手順を繰り返す必要はありません:

```gherkin
# 冗長（借りる手順をいちいち書いている）
Given 会員 "DA-8821" が登録されている
And 書籍 "Book 1" が登録されている
And 書籍 "Book 2" が登録されている
When 会員 "DA-8821" が書籍 "Book 1" を借りる
And 会員 "DA-8821" が書籍 "Book 2" を借りる
Then 会員 "DA-8821" の貸出冊数が 2 になる

# 簡潔（状態を宣言するだけ）
Given 会員 "DA-8821" が登録されている
And 会員 "DA-8821" が 2 冊借りている状態である
Then 会員 "DA-8821" の貸出冊数が 2 になる
```

この手法は、テストの関心が「借りる行為」ではなく「借りた後の状態」にある場合に有効です。

### 5.4 曖昧な表現を避ける

```gherkin
# 曖昧（誰が借りているのか不明）
Given 書籍 "Neuromancer" が既に借りられている

# 明確（誰が借りているか分かる）
Given 会員 "田中次郎" (ID: "DA-1156") が登録されている
And 会員 "DA-1156" が書籍 "Neuromancer" を既に借りている
```

### 5.5 自明な検証は書かない

```gherkin
# 冗長（「既に借りている」の直後に貸出冊数1を確認する必要はない）
Given 会員 "DA-8821" が書籍 "The Infinite Library" を既に借りている
And 会員 "DA-8821" の現在の貸出冊数は 1 である
When 会員 "DA-8821" が書籍 "The Infinite Library" を返却する

# 簡潔（1冊借りているのは前の行から自明）
Given 会員 "DA-8821" が書籍 "The Infinite Library" を既に借りている
When 会員 "DA-8821" が書籍 "The Infinite Library" を返却する
```

### 5.6 各シナリオは独立させる

シナリオ間で状態を共有してはいけません。各シナリオは単独で実行でき、同じ結果が得られる必要があります。

## 6. 本プロジェクトでの実践

### テスト構成

本プロジェクトでは、テストを2層に分けています:

| レイヤー | フレームワーク | 実行方法 | 目的 |
|---------|-------------|---------|------|
| ユニット/ロジック | XCTest | `swift test` | ビジネスロジックの検証（高速・安定） |
| E2E/UI | CucumberSwift + XCUITest | `xcodebuild test` | 画面操作の受け入れテスト |

### ディレクトリ構成

```
Sources/Libratta/                      # プロダクションコード
├── Models/                            # ドメインモデル
├── Repositories/                      # データアクセス
├── UseCases/                          # ビジネスロジック
└── Auth/                              # 認証

Libratta/                              # SwiftUI アプリ
├── App/                               # エントリポイント・ルーティング
├── Views/                             # SwiftUI ビュー
└── ViewModels/                        # ViewModel

LibrattaTests/                         # ユニットテスト（XCTest）
├── Features/                          # feature ファイル（仕様ドキュメント）
│   ├── borrowing_flow.feature
│   ├── book_management.feature
│   └── ...
└── Steps/                             # ステップ定義（XCTest メソッド）
    ├── BorrowingFlowStepTests.swift
    ├── BookManagementStepTests.swift
    └── ...

LibrattaUITests/                       # UIテスト（CucumberSwift + XCUITest）
├── Features/                          # UI feature ファイル
│   ├── login_ui.feature
│   ├── member_ui.feature
│   ├── book_catalog_ui.feature
│   └── borrowing_flow_ui.feature
├── PageObjects/                       # Page Object パターン
│   ├── LoginPage.swift
│   ├── TopPage.swift
│   ├── MemberListPage.swift
│   ├── BookCatalogPage.swift
│   └── LoanConfirmationPage.swift
└── LibrattaUITests.swift              # CucumberSwift ステップ定義
```

### feature ファイルからステップ定義への対応

#### ユニットテスト層（XCTest）

feature ファイルの各シナリオは、XCTest のテストメソッドに手動で対応させています:

**feature ファイル:**
```gherkin
Scenario: 会員が書籍を借りる
  Given 会員 "山田太郎" (ID: "DA-8821") が登録されている
  And 書籍 "The Infinite Library" が登録されている
  When 会員 "DA-8821" が書籍 "The Infinite Library" を借りる
  Then 書籍 "The Infinite Library" は貸出中である
```

**ステップ定義 (Swift/XCTest):**
```swift
func testSmoke_会員が書籍を借りる() throws {
    // Given
    let member = Member(id: "DA-8821", name: "山田太郎")
    try memberRepo.save(member)
    let book = Book(title: "The Infinite Library", ...)
    try bookRepo.save(book)

    // When
    let result = borrowBookUseCase.execute(
        memberId: "DA-8821", bookTitle: "The Infinite Library"
    )

    // Then
    XCTAssertNotNil(loanRepo.findActiveByBookId(book.id))
}
```

> **注意**: iOS の XCTest 層では、Cucumber のような自動ステップマッチングは行いません。
> feature ファイルは仕様ドキュメントとして管理し、テストメソッドは手動で対応させます。

#### UIテスト層（CucumberSwift）

UI feature ファイルは CucumberSwift が自動的にパースし、XCTestCase を生成します:

**feature ファイル:**
```gherkin
Scenario: 書籍カタログ画面に書籍カードが表示される
  Given 書籍カタログ画面が会員 "Taro Yamada" で表示されている
  Then 書籍 "The Infinite Library" のカードが表示されている
```

**ステップ定義 (CucumberSwift):**
```swift
Given("書籍カタログ画面が会員 {string} で表示されている") { matches, _ in
    let memberName = matches[1]
    LoginPage(app: app).login(email: "test@example.com", password: "pass123")
    TopPage(app: app).tapBorrowingCard()
    MemberListPage(app: app).tapMember(memberName)
    BookCatalogPage(app: app).verifyDisplayed()
}
```

### @smoke タグによるテスト絞り込み

`@smoke` タグ付きシナリオに対応するテストメソッドには `Smoke` プレフィックスを付けます:

```bash
# スモークテストのみ（CI の高速フィードバック用）
swift test --filter Smoke

# 全テスト
swift test
```

詳細は [iOS BDD テストにおける @smoke タグの制約と回避策](ios-bdd-tag-constraints.md) を参照してください。

### 開発の流れ

#### Step 1: feature ファイルを作成する

`LibrattaTests/Features/` に `.feature` ファイルを作成します。

```gherkin
Feature: 貸出上限
  会員が借りられる冊数には上限がある

  Scenario: 貸出上限に達している場合は借りられない
    Given 会員 "山田太郎" (ID: "DA-8821") が登録されている
    And 会員 "DA-8821" が 3 冊借りている状態である
    And 書籍 "Neuromancer" が登録されている
    When 会員 "DA-8821" が書籍 "Neuromancer" を借りようとする
    Then エラーメッセージ "貸出上限（3冊）に達しています" が返される
```

#### Step 2: ステップ定義を実装する

`LibrattaTests/Steps/` にテストクラスを作成し、feature シナリオに対応するテストメソッドを実装します。

#### Step 3: プロダクションコードを実装する

テストが通るように `Sources/Libratta/` のコードを実装します。

#### Step 4: テストと Lint を確認する

```bash
swift test                    # 全ユニットテスト実行
swift test --filter Smoke     # スモークテストのみ
swiftlint                    # 静的解析
```

#### Step 5: Xcode でビルド・UIテストを実行する

```bash
xcodegen generate             # Xcode プロジェクト再生成
xcodebuild test \
  -project Libratta.xcodeproj \
  -scheme LibrattaUITests \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

### コミットメッセージ規約

| プレフィックス | フェーズ | 例 |
|---------------|---------|-----|
| `test:` | テスト追加 | `test: 貸出上限の受け入れテストを追加` |
| `impl:` | 実装 | `impl: BorrowBookUseCase に貸出上限チェックを追加` |
| `refactor:` | リファクタリング | `refactor: feature ファイルの Given/Then 表現を整理` |
| `docs:` | ドキュメント | `docs: ATDD ガイドを追加` |
| `build:` | ビルド設定 | `build: CucumberSwift 依存を追加` |
| `api:` | API 変更 | `api: 貸出 API のレスポンス形式を変更` |

## 7. よくある質問

### Q: シナリオはどのくらい細かく書くべき？

1 シナリオにつき 1 つのルール（振る舞い）をテストします。複数のことを検証するシナリオは、分割を検討してください。

### Q: 正常系と異常系、どちらを先に書く？

正常系を先に書きます。基本的な動作が確認できてから、異常系（エラーケース・境界値）を追加していきます。

### Q: ステップ定義はどこまで再利用すべき？

ユニットテスト層では XCTest メソッドなので再利用は意識しません。UIテスト層では CucumberSwift が同じステップ表現を自動的にマッチングします。ただし、無理に再利用するために表現を歪めるのは避けてください。読みやすさが最優先です。

### Q: UI テストとユニットテストの feature ファイルは分ける？

はい。ビジネスロジックのテストは `LibrattaTests/Features/`（`swift test` で高速・安定に実行）、UI の振る舞いテストは `LibrattaUITests/Features/`（`xcodebuild test` でシミュレータ使用）に配置します。

### Q: feature ファイルは日本語で書いてもいい？

はい。Gherkin はキーワード（Given/When/Then）以外は自由な言語で書けます。本プロジェクトではシナリオ本文を日本語で記述しています。

### Q: Android と feature ファイルは同じ？

はい。ユニットテスト層の feature ファイルは Android プロジェクトと完全に同一です。UI テスト層の feature ファイルはプラットフォーム固有の操作があるため、iOS 専用です。

### Q: CucumberSwift に制約はある？

あります。詳細は [iOS BDD テストにおける @smoke タグの制約と回避策](ios-bdd-tag-constraints.md) を参照してください。主な制約:

- feature ファイル内の `@` 文字がパースエラーを引き起こす
- `And` キーワードのステップが正しくマッチングされないケースがある
- ユニットテスト層では CucumberSwift を使わず XCTest で手動対応
