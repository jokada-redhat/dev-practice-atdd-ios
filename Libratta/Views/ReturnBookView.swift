import SwiftUI

struct ReturnBookView: View {
    @ObservedObject var viewModel: ReturnBookViewModel
    @State private var itemToReturn: LoanedItem?

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()

            Group {
                if viewModel.loanedItems.isEmpty && viewModel.searchQuery.isEmpty {
                    ContentUnavailableView(
                        "現在貸し出し中の書籍はありません",
                        systemImage: "book.closed",
                        description: Text("すべての書籍が返却済みです")
                    )
                } else {
                    VStack(spacing: 0) {
                        HStack {
                            Text("\(viewModel.loanedItems.count)件の貸出中書籍")
                                .font(.caption)
                                .foregroundStyle(AppTheme.onSurfaceVariant)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)

                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.loanedItems) { item in
                                    LoanedItemCard(item: item) {
                                        itemToReturn = item
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
        }
        .searchable(text: $viewModel.searchQuery, prompt: "書籍名・ISBN・会員名・IDで検索")
        .onChange(of: viewModel.searchQuery) { _, _ in
            viewModel.loadLoans()
        }
        .navigationTitle("書籍の返却")
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

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    var body: some View {
        HStack(spacing: 12) {
            // Book icon placeholder
            Image(systemName: "book.closed.fill")
                .font(.title2)
                .foregroundStyle(AppTheme.primaryContainer)
                .frame(width: 48, height: 64)
                .background(AppTheme.surfaceContainerHigh)
                .clipShape(RoundedRectangle(cornerRadius: 6))

            VStack(alignment: .leading, spacing: 6) {
                Text(item.bookTitle)
                    .font(.headline)
                    .foregroundStyle(AppTheme.onSurface)

                Text("貸出日: \(Self.dateFormatter.string(from: item.borrowedDate))")
                    .font(.caption)
                    .foregroundStyle(AppTheme.onSurfaceVariant)

                HStack(spacing: 4) {
                    Image(systemName: "person.fill")
                        .font(.caption2)
                        .foregroundStyle(AppTheme.outline)
                    Text("\(item.memberName) \(item.memberId)")
                        .font(.caption)
                        .foregroundStyle(AppTheme.onSurfaceVariant)
                }
            }

            Spacer()

            Button {
                onReturn()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.uturn.left")
                        .font(.caption)
                    Text("返却")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(AppTheme.surfaceContainerHigh)
                .foregroundStyle(AppTheme.onSurface)
                .clipShape(Capsule())
            }
        }
        .stitchCard()
    }
}
