import SwiftUI

struct ReturnBookView: View {
    @ObservedObject var viewModel: ReturnBookViewModel
    @State private var itemToReturn: LoanedItem?

    var body: some View {
        Group {
            if viewModel.loanedItems.isEmpty && viewModel.searchQuery.isEmpty {
                ContentUnavailableView(
                    "現在貸し出し中の書籍はありません",
                    systemImage: "book.closed",
                    description: Text("すべての書籍が返却済みです")
                )
            } else {
                List {
                    ForEach(viewModel.loanedItems) { item in
                        LoanedItemCard(item: item) {
                            itemToReturn = item
                        }
                    }
                }
            }
        }
        .searchable(text: $viewModel.searchQuery, prompt: "書籍名・ISBN・会員名・IDで検索")
        .onChange(of: viewModel.searchQuery) { _, _ in
            viewModel.loadLoans()
        }
        .navigationTitle("返却 (\(viewModel.loanedItems.count)冊)")
        .onAppear {
            viewModel.loadLoans()
        }
        .confirmationDialog(
            "返却確認",
            isPresented: Binding(
                get: { itemToReturn != nil },
                set: { if !$0 { itemToReturn = nil } }
            ),
            presenting: itemToReturn
        ) { item in
            Button("返却する") {
                viewModel.returnBook(item)
                itemToReturn = nil
            }
            Button("キャンセル", role: .cancel) {
                itemToReturn = nil
            }
        } message: { item in
            Text("「\(item.bookTitle)」を返却しますか？")
        }
        .alert("エラー", isPresented: $viewModel.showReturnAlert) {
            Button("OK") {}
        } message: {
            Text(viewModel.returnResult ?? "")
        }
    }
}

struct LoanedItemCard: View {
    let item: LoanedItem
    let onReturn: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.bookTitle)
                    .font(.headline)
                HStack {
                    Image(systemName: "person")
                        .font(.caption)
                    Text(item.memberName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Text("ISBN: \(item.bookIsbn)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            Spacer()
            Button("返却") {
                onReturn()
            }
            .buttonStyle(.bordered)
            .tint(.green)
        }
        .padding(.vertical, 4)
    }
}
