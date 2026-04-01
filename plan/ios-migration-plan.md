# iOS マイグレーション計画書

## 概要

Android (Libretta) → iOS (Libratta) へのマイグレーション。
ATDD のイテレーション順に段階的に実装する。Feature ファイルは Android 版と同一のものを使用。

## 技術マッピング

| Android | iOS (Libratta) |
|---------|-----------------|
| Kotlin | Swift |
| Activity + XML Layout | SwiftUI Views |
| ViewModel (LiveData) | ObservableObject (@Published) |
| SharedPreferences | UserDefaults |
| OkHttp3 | URLSession |
| Espresso + cucumber-android | XCUITest (UI feature は後日対応) |
| cucumber-java (JVM) | CucumberSwift (XCTest) |
| InMemoryRepository | そのまま移植 (Swift protocol + class) |
| Gradle (Kotlin DSL) | Swift Package Manager |
| Android Lint | SwiftLint |
| MockWebServer | URLProtocol mock |

## アーキテクチャ

```
Libratta/
├── App/
│   └── LibrattaApp.swift
├── Models/
│   ├── Member.swift
│   ├── Book.swift
│   └── Loan.swift
├── Repositories/
│   ├── MemberRepository.swift
│   ├── BookRepository.swift
│   ├── LoanRepository.swift
│   └── InMemory/
│       ├── InMemoryMemberRepository.swift
│       ├── InMemoryBookRepository.swift
│       └── InMemoryLoanRepository.swift
├── UseCases/
│   ├── RegisterMemberUseCase.swift
│   ├── ListMembersUseCase.swift
│   ├── SearchBooksUseCase.swift
│   ├── BorrowBookUseCase.swift
│   └── ReturnBookUseCase.swift
├── Auth/
│   ├── LoginRequest.swift
│   ├── LoginResult.swift
│   ├── AuthRepository.swift
│   ├── StubAuthRepository.swift
│   └── AuthApiClient.swift
├── Session/
│   ├── SessionRepository.swift
│   ├── UserDefaultsSessionRepository.swift
│   └── SessionManager.swift
├── ViewModels/
│   ├── LoginViewModel.swift
│   ├── MemberListViewModel.swift
│   ├── BookCatalogViewModel.swift
│   └── LoanViewModel.swift
└── Views/
    ├── LoginView.swift
    ├── TopView.swift
    ├── MemberListView.swift
    ├── AddMemberView.swift
    ├── BookCatalogView.swift
    ├── BookListView.swift
    ├── ReturnBookView.swift
    └── LoanConfirmationView.swift
```

## イテレーション計画

### Iteration 1: ログイン機能 (ドメイン + テスト)

**Feature ファイル**: login.feature, login_api.feature, session.feature, skip_auth.feature, sample.feature

**実装内容**:
- Models: LoginRequest, LoginResult
- Auth: AuthRepository (protocol), StubAuthRepository
- Session: SessionRepository (protocol), UserDefaultsSessionRepository (InMemory版), SessionManager
- Auth: AuthApiClient (URLSession)
- CucumberSwift セットアップ
- ステップ定義: LoginSteps, LoginApiSteps, SessionSteps, SkipAuthSteps, SampleSteps

### Iteration 2: 会員管理 (ドメイン + テスト)

**Feature ファイル**: member_management.feature

**実装内容**:
- Models: Member
- Repositories: MemberRepository (protocol), InMemoryMemberRepository
- UseCases: RegisterMemberUseCase, ListMembersUseCase
- ステップ定義: MemberManagementSteps

### Iteration 3: 書籍カタログ (ドメイン + テスト)

**Feature ファイル**: book_catalog.feature, book_management.feature

**実装内容**:
- Models: Book, BookStatus
- Repositories: BookRepository (protocol), InMemoryBookRepository
- UseCases: SearchBooksUseCase
- ステップ定義: BookCatalogSteps, BookManagementSteps

### Iteration 4: 貸出・返却フロー (ドメイン + テスト)

**Feature ファイル**: borrowing_flow.feature, return_book.feature, return_from_list.feature

**実装内容**:
- Models: Loan
- Repositories: LoanRepository (protocol), InMemoryLoanRepository
- UseCases: BorrowBookUseCase, ReturnBookUseCase
- ステップ定義: BorrowingFlowSteps, ReturnBookSteps, ReturnFromListSteps

### Iteration 5: SwiftUI ビュー実装

**実装内容**:
- ViewModels: LoginViewModel, MemberListViewModel, BookCatalogViewModel, LoanViewModel
- Views: 全画面 (SwiftUI)
- Navigation: NavigationStack ベース

### Iteration 6: UI テスト (将来)

**Feature ファイル**: login_ui.feature, member_ui.feature, book_catalog_ui.feature, borrowing_flow_ui.feature

**実装内容**:
- XCUITest + feature ファイル連携
- UI ステップ定義

## CucumberSwift について

- Swift Package: `nicklawls/CucumberSwift` (SPM 対応)
- XCTest と統合して Cucumber シナリオを実行
- feature ファイルはテストターゲットの Resources に配置
