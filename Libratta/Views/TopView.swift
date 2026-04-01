import SwiftUI

struct TopView: View {
    @ObservedObject var viewModel: TopViewModel
    var onLogout: () -> Void
    var onBorrowing: () -> Void
    var onReturns: () -> Void
    var onBookList: () -> Void
    var onDebugSettings: (() -> Void)?

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading) {
                    Text("ようこそ")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(viewModel.displayName)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .accessibilityIdentifier("displayName")
                }
                Spacer()
                Button("ログアウト") {
                    viewModel.logout()
                    onLogout()
                }
                .accessibilityIdentifier("logoutButton")
            }
            .padding()

            VStack(spacing: 16) {
                MenuCard(
                    title: "貸し出し",
                    subtitle: "会員を選択して書籍を貸し出す",
                    systemImage: "book.and.wrench",
                    color: .blue
                ) {
                    onBorrowing()
                }

                MenuCard(
                    title: "返却",
                    subtitle: "貸し出し中の書籍を返却する",
                    systemImage: "arrow.uturn.left.circle",
                    color: .green
                ) {
                    onReturns()
                }

                MenuCard(
                    title: "書籍一覧",
                    subtitle: "書籍の検索・登録",
                    systemImage: "books.vertical",
                    color: .orange
                ) {
                    onBookList()
                }
            }
            .padding(.horizontal)

            Spacer()
        }
        .navigationTitle("Libratta")
        .navigationBarBackButtonHidden()
        .toolbar {
            if let onDebugSettings {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            onDebugSettings()
                        } label: {
                            Label("デバッグ設定", systemImage: "wrench.and.screwdriver")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
    }
}

struct MenuCard: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: systemImage)
                    .font(.title)
                    .foregroundStyle(color)
                    .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
    }
}
