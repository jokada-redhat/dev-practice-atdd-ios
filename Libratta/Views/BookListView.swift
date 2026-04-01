import SwiftUI

struct BookListView: View {
    @ObservedObject var viewModel: BookListViewModel
    @State private var showAddBook = false
    var addBookViewModelFactory: () -> AddBookViewModel

    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Count & Filter Bar
                HStack {
                    Text("\(viewModel.books.count)冊の書籍")
                        .font(.caption)
                        .foregroundStyle(AppTheme.onSurfaceVariant)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)

                // Book List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.books) { book in
                            BookListCard(book: book)
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
        .navigationTitle("書籍一覧")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAddBook = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddBook) {
            viewModel.loadBooks()
        } content: {
            NavigationStack {
                AddBookView(viewModel: addBookViewModelFactory())
            }
        }
        .onAppear {
            viewModel.loadBooks()
        }
    }
}

struct BookListCard: View {
    let book: Book

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(book.title)
                    .font(.headline)
                    .foregroundStyle(AppTheme.onSurface)
                Spacer()
                StatusBadge(
                    text: book.isAvailable ? "貸出可" : "貸出中",
                    isAvailable: book.isAvailable
                )
            }

            Text(book.author)
                .font(.subheadline)
                .foregroundStyle(AppTheme.onSurfaceVariant)

            HStack {
                Text("ISBN: \(book.isbn)")
                    .font(.caption2)
                    .foregroundStyle(AppTheme.outline)
                Spacer()
                Text("出版年 \(String(book.publicationYear))")
                    .font(.caption2)
                    .foregroundStyle(AppTheme.outline)
            }
        }
        .stitchCard()
    }
}
