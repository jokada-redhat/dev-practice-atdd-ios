import SwiftUI

struct TopView: View {
    @ObservedObject var viewModel: TopViewModel
    var onLogout: () -> Void
    var onBorrowing: () -> Void
    var onReturns: () -> Void
    var onBookList: () -> Void
    var onDebugSettings: (() -> Void)?

    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    // Profile Card
                    HStack(spacing: 12) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(AppTheme.primary)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("司書プロフィール")
                                .font(.caption2)
                                .foregroundStyle(AppTheme.onSurfaceVariant)
                                .textCase(.uppercase)
                            Text(viewModel.displayName)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(AppTheme.onSurface)
                                .accessibilityIdentifier("displayName")
                        }
                        Spacer()
                    }
                    .padding(16)
                    .background(AppTheme.surfaceContainerLow)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    // Action 1: Borrowing (Primary)
                    Button {
                        onBorrowing()
                    } label: {
                        VStack(spacing: 16) {
                            Image(systemName: "text.book.closed")
                                .font(.system(size: 48))
                                .foregroundStyle(.white)

                            Text("図書の貸し出し")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)

                            Text("書籍を選んで貸し出す")
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.primaryFixed.opacity(0.8))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(32)
                        .background(AppTheme.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                    }
                    .buttonStyle(.plain)

                    // Action 2: Returns
                    Button {
                        onReturns()
                    } label: {
                        VStack(spacing: 16) {
                            Image(systemName: "arrow.uturn.left.circle")
                                .font(.system(size: 48))
                                .foregroundStyle(AppTheme.primary)

                            Text("返却")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(AppTheme.onSurface)

                            Text("書籍を返却する")
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.onSurfaceVariant)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(32)
                        .background(AppTheme.surfaceContainerHigh)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(AppTheme.outlineVariant, lineWidth: 2)
                        )
                    }
                    .buttonStyle(.plain)

                    // Action 3: Book Management
                    Button {
                        onBookList()
                    } label: {
                        VStack(spacing: 16) {
                            Image(systemName: "books.vertical")
                                .font(.system(size: 48))
                                .foregroundStyle(AppTheme.secondary)

                            Text("書籍管理")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(AppTheme.onSurface)

                            Text("書籍の一覧・登録")
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.onSurfaceVariant)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(32)
                        .background(AppTheme.surfaceContainerLow)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(AppTheme.outlineVariant, lineWidth: 2)
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(24)
            }
        }
        .navigationTitle("Libratta")
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        viewModel.logout()
                        onLogout()
                    } label: {
                        Label("ログアウト", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                    .accessibilityIdentifier("logoutButton")

                    if let onDebugSettings {
                        Button {
                            onDebugSettings()
                        } label: {
                            Label("デバッグ設定", systemImage: "wrench.and.screwdriver")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }
}
