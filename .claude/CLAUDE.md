# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## プロジェクト概要

iOS アプリの ATDD (Acceptance Test Driven Development) 実践リポジトリ。Cucumber による受け入れテスト駆動で iOS アプリとバックエンド API を開発する。

## 技術スタック

- **言語**: Swift
- **IDE**: Xcode
- **ビルド**: Xcode Build System / Swift Package Manager (SPM)
- **テストフレームワーク**: Cucumber (CucumberSwift / Gherkin feature files)
- **UIテスト**: XCUITest
- **ユニットテスト**: XCTest
- **静的解析**: SwiftLint
- **バックエンドAPI**: REST API (テスト用モック/スタブを含む)

## プロジェクト構成

```
Libratta/
├── Libratta/
│   ├── App/                   # アプリエントリポイント
│   ├── Views/                 # SwiftUI ビュー
│   ├── Models/                # データモデル
│   ├── ViewModels/            # ViewModel
│   ├── Services/              # API通信・データアクセス
│   └── Resources/             # アセット・リソース
├── LibrattaTests/
│   ├── Features/              # Cucumber feature ファイル (.feature)
│   ├── CucumberRunner/        # CucumberSwift ステップ定義
│   │   ├── LibrattaTestRunner.swift
│   │   ├── ScenarioContext.swift
│   │   └── Steps/             # feature ごとのステップ定義
│   └── Support/               # テストユーティリティ
├── LibrattaUITests/
│   ├── Features/              # UI向け Cucumber feature ファイル
│   ├── Steps/                 # feature ごとの UIステップ定義
│   ├── PageObjects/           # Page Object パターン
│   └── LibrattaUITests.swift  # CucumberSwift ランナー
├── Package.swift              # SPM 依存管理 (使用する場合)
└── .swiftlint.yml             # SwiftLint 設定
```

## ATDDワークフロー

1. **受け入れ条件の定義**: ビジネス要件から Cucumber feature ファイルを作成 (.feature)
2. **ステップ定義の実装**: Given-When-Then に対応する Swift ステップ定義を作成
3. **機能の実装**: テストが通るようにプロダクションコードを実装
4. **リファクタリング**: テストを維持しながらコードを改善
5. **Lint チェック**: SwiftLint で静的解析を実行し品質を確保

## 開発コマンド

```bash
# ビルド (SPM)
swift build

# ユニットテスト実行 (SPM - 推奨)
swift test

# ビルド (Xcode)
xcodebuild build -project Libratta.xcodeproj -scheme Libratta -destination 'platform=iOS Simulator,name=iPhone 17 Pro'

# ユニットテスト実行 (Xcode)
xcodebuild test -project Libratta.xcodeproj -scheme LibrattaTests -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:LibrattaTests

# UIテスト実行 (Xcode)
xcodebuild test -project Libratta.xcodeproj -scheme LibrattaUITests -destination 'platform=iOS Simulator,name=iPhone 17 Pro'

# Xcode プロジェクト再生成 (project.yml 変更後)
xcodegen generate

# SwiftLint 実行
swiftlint
```

## 開発原則

### テストファースト

- Cucumber feature ファイルを先に作成
- ステップ定義を Swift で実装
- プロダクションコードを実装してテストをパス

### テストシナリオの記述

- **Given-When-Then構造**: 前提条件、アクション、期待結果を明確に分離
- **ビジネス言語**: 技術用語ではなく、ビジネス要件を反映した表現を使用
- **独立性**: 各シナリオは他のシナリオに依存しない
- **再現性**: 同じ条件で実行すれば同じ結果が得られる

### バックエンド API テスト

- API のインターフェース (リクエスト/レスポンス) を先に定義
- Cucumber でAPI の振る舞いを記述
- モック/スタブを活用してフロントエンドとバックエンドを独立にテスト

### コード品質

- SwiftLint の警告をゼロに保つ
- 実装コードは適切なレイヤーに配置 (Views / ViewModels / Models / Services)
- ステップ定義は再利用可能に設計
- 単一責任の原則に従う

## コミットメッセージ規約

ATDDのフェーズを明確にするため、プレフィックスを使用：

- `test:` - 受け入れテスト (feature ファイル / ステップ定義) の追加・修正
- `impl:` - テストを通すための実装
- `refactor:` - リファクタリング
- `docs:` - ドキュメントの更新
- `build:` - ビルド設定・Xcode 設定の変更
- `api:` - バックエンド API 定義・実装の変更

テストと実装を同時にコミットせず、フェーズを分けてコミットすることでATDDのプロセスを明確にします。
