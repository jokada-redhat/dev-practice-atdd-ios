import SwiftUI

struct BookCatalogView: View {
    @ObservedObject var viewModel: BookCatalogViewModel
    @State private var bookToBorrow: Book?
    var onLoanConfirmed: (Member, Book) -> Void

    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Selected Member
                if let member = viewModel.selectedMember {
                    HStack(spacing: 8) {
                        Image(systemName: "person.circle.fill")
                            .foregroundStyle(AppTheme.primary)
                        Text("選択中の会員:")
                            .font(.caption)
                            .foregroundStyle(AppTheme.onSurfaceVariant)
                        Text(member.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(AppTheme.onSurface)
                            .accessibilityIdentifier("selectedMember")
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(AppTheme.primaryFixed.opacity(0.5))
                }

                // Filter
                Picker("フィルタ", selection: $viewModel.selectedFilter) {
                    ForEach(BookFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .onChange(of: viewModel.selectedFilter) { _, _ in
                    viewModel.loadBooks()
                }

                // Book Cards
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.books) { book in
                            let available = viewModel.isBookAvailable(book)
                            CatalogBookCard(
                                book: book,
                                isAvailable: available
                            ) {
                                bookToBorrow = book
                            }
                            .accessibilityIdentifier("bookCard_\(book.isbn)")
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .searchable(text: $viewModel.searchQuery, prompt: "タイトル・著者・ISBNで検索")
        .onChange(of: viewModel.searchQuery) { _, _ in
            viewModel.loadBooks()
        }
        .navigationTitle("書籍カタログ")
        .onAppear {
            viewModel.loadBooks()
        }
        .confirmationDialog(
            "貸し出し確認",
            isPresented: Binding(
                get: { bookToBorrow != nil },
                set: { if !$0 { bookToBorrow = nil } }
            ),
            presenting: bookToBorrow
        ) { book in
            Button("貸し出す") {
                if let member = viewModel.selectedMember {
                    viewModel.borrowBook(book)
                    if viewModel.borrowResult == nil {
                        onLoanConfirmed(member, book)
                    }
                }
                bookToBorrow = nil
            }
            Button("キャンセル", role: .cancel) {
                bookToBorrow = nil
            }
        } message: { book in
            Text("「\(book.title)」を貸し出しますか？")
        }
        .alert("エラー", isPresented: $viewModel.showBorrowAlert) {
            Button("OK") {}
        } message: {
            Text(viewModel.borrowResult ?? "")
        }
    }
}

struct CatalogBookCard: View {
    let book: Book
    let isAvailable: Bool
    let onBorrow: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                StatusBadge(
                    text: isAvailable ? "貸出可" : "貸出中",
                    isAvailable: isAvailable
                )
                Spacer()
            }

            Text(book.title)
                .font(.headline)
                .foregroundStyle(AppTheme.onSurface)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("著者:")
                        .font(.caption)
                        .foregroundStyle(AppTheme.outline)
                    Text(book.author)
                        .font(.caption)
                        .foregroundStyle(AppTheme.onSurfaceVariant)
                }
                HStack {
                    Text("ISBN:")
                        .font(.caption)
                        .foregroundStyle(AppTheme.outline)
                    Text(book.isbn)
                        .font(.caption)
                        .foregroundStyle(AppTheme.onSurfaceVariant)
                }
                HStack {
                    Text("出版年:")
                        .font(.caption)
                        .foregroundStyle(AppTheme.outline)
                    Text(String(book.publicationYear))
                        .font(.caption)
                        .foregroundStyle(AppTheme.onSurfaceVariant)
                }
            }

            if isAvailable {
                HStack {
                    Spacer()
                    Button {
                        onBorrow()
                    } label: {
                        Text("貸し出す")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(AppTheme.primaryGradient)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                    .accessibilityIdentifier("borrowButton_\(book.isbn)")
                }
            }
        }
        .stitchCard()
    }
}
