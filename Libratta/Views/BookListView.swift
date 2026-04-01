import SwiftUI

struct BookListView: View {
    @ObservedObject var viewModel: BookListViewModel
    @State private var showAddBook = false
    var addBookViewModelFactory: () -> AddBookViewModel

    var body: some View {
        List {
            ForEach(viewModel.books) { book in
                VStack(alignment: .leading, spacing: 4) {
                    Text(book.title)
                        .font(.headline)
                    HStack {
                        Text(book.author)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(String(book.publicationYear))
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    Text("ISBN: \(book.isbn)")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                .padding(.vertical, 4)
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
