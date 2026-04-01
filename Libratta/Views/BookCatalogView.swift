import SwiftUI

struct BookCatalogView: View {
    @ObservedObject var viewModel: BookCatalogViewModel
    @State private var bookToBorrow: Book?
    var onLoanConfirmed: (Member, Book) -> Void

    var body: some View {
        VStack(spacing: 0) {
            if let member = viewModel.selectedMember {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .foregroundStyle(.blue)
                    Text(member.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .accessibilityIdentifier("selectedMember")
                    Spacer()
                }
                .padding()
                .background(.blue.opacity(0.05))
            }

            Picker("フィルタ", selection: $viewModel.selectedFilter) {
                ForEach(BookFilter.allCases, id: \.self) { filter in
                    Text(filter.rawValue).tag(filter)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.vertical, 8)
            .onChange(of: viewModel.selectedFilter) { _, _ in
                viewModel.loadBooks()
            }

            List {
                ForEach(viewModel.books) { book in
                    BookCard(book: book) {
                        bookToBorrow = book
                    }
                    .accessibilityIdentifier("bookCard_\(book.isbn)")
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

struct BookCard: View {
    let book: Book
    let onBorrow: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.headline)
                Text(book.author)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("ISBN: \(book.isbn)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            Spacer()
            if book.isAvailable {
                Button("貸出") {
                    onBorrow()
                }
                .buttonStyle(.bordered)
                .tint(.blue)
                .accessibilityIdentifier("borrowButton_\(book.isbn)")
            } else {
                Text("貸出中")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.red.opacity(0.1))
                    .foregroundStyle(.red)
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 4)
    }
}
