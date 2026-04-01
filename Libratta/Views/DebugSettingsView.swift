import SwiftUI

struct DebugSettingsView: View {
    @EnvironmentObject var deps: AppDependencies
    @State private var bookCount = 0
    @State private var memberCount = 0
    @State private var loanCount = 0
    @State private var showLoadConfirm = false
    @State private var showClearConfirm = false

    var body: some View {
        List {
            Section("データ状況") {
                HStack {
                    Text("書籍数")
                    Spacer()
                    Text("\(bookCount)")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("会員数")
                    Spacer()
                    Text("\(memberCount)")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("貸出中")
                    Spacer()
                    Text("\(loanCount)")
                        .foregroundStyle(.secondary)
                }
            }

            Section("操作") {
                Button("ダミーデータを読み込む") {
                    showLoadConfirm = true
                }

                Button("全データをクリア", role: .destructive) {
                    showClearConfirm = true
                }
            }

            Section("テスト用アカウント") {
                HStack {
                    Text("メール")
                    Spacer()
                    Text("test@example.com")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
                HStack {
                    Text("パスワード")
                    Spacer()
                    Text("pass123")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
            }
        }
        .navigationTitle("デバッグ設定")
        .onAppear { updateCounts() }
        .confirmationDialog("ダミーデータを読み込みますか？", isPresented: $showLoadConfirm, titleVisibility: .visible) {
            Button("読み込む") {
                loadDummyData()
            }
        } message: {
            Text("既存のデータはクリアされます")
        }
        .confirmationDialog("全データをクリアしますか？", isPresented: $showClearConfirm, titleVisibility: .visible) {
            Button("クリア", role: .destructive) {
                clearAll()
            }
        } message: {
            Text("この操作は取り消せません")
        }
    }

    private func updateCounts() {
        bookCount = deps.bookRepository.findAll().count
        memberCount = deps.memberRepository.findAll().count
        loanCount = deps.loanRepository.findAllActive().count
    }

    private func loadDummyData() {
        deps.memberRepository.clear()
        deps.bookRepository.clear()
        deps.loanRepository.clear()

        let generator = DummyDataGenerator(
            memberRepository: deps.memberRepository,
            bookRepository: deps.bookRepository,
            loanRepository: deps.loanRepository
        )
        generator.generate()
        updateCounts()
    }

    private func clearAll() {
        deps.memberRepository.clear()
        deps.bookRepository.clear()
        deps.loanRepository.clear()
        updateCounts()
    }
}
