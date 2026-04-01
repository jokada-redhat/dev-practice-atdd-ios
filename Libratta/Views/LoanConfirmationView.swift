import SwiftUI

struct LoanConfirmationView: View {
    let memberName: String
    let bookTitle: String
    let bookAuthor: String
    let memberId: String
    var onDone: () -> Void

    @State private var countdown = 30

    private var dueDateString: String {
        let dueDate = Calendar.current.date(byAdding: .weekOfYear, value: 2, to: Date()) ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: dueDate)
    }

    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    Spacer(minLength: 32)

                    // Success Icon
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(AppTheme.primary)

                    // Title
                    Text("貸し出しが完了しました")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(AppTheme.onSurface)
                        .multilineTextAlignment(.center)

                    Text("手続きが正常に処理されました")
                        .font(.callout)
                        .foregroundStyle(AppTheme.onSurfaceVariant)
                        .padding(.bottom, 8)

                    // Loan Summary Card
                    VStack(alignment: .leading, spacing: 16) {
                        Text("貸し出し情報")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(AppTheme.onSurfaceVariant)
                            .textCase(.uppercase)

                        // Book Info
                        VStack(alignment: .leading, spacing: 4) {
                            Text("貸し出し書籍")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundStyle(AppTheme.outline)
                                .textCase(.uppercase)
                            Text(bookTitle)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(AppTheme.onSurface)
                            Text(bookAuthor)
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.onSurfaceVariant)
                        }
                        .padding(.bottom, 4)

                        Divider()
                            .background(AppTheme.surfaceContainerHigh)

                        // Member & Due Date (2 columns)
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("借り手")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(AppTheme.outline)
                                    .textCase(.uppercase)
                                Text(memberName)
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(AppTheme.onSurface)
                                Text("ID: \(memberId)")
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.onSurfaceVariant)
                            }
                            Spacer()
                            VStack(alignment: .leading, spacing: 4) {
                                Text("返却期限")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(AppTheme.outline)
                                    .textCase(.uppercase)
                                Text(dueDateString)
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(AppTheme.onSurface)
                                Text("2週間")
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.onSurfaceVariant)
                            }
                        }
                    }
                    .padding(24)
                    .background(AppTheme.surfaceContainerLowest)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 24)

                    // Auto-redirect Timer
                    Text("\(countdown)秒後に自動的にホームに戻ります")
                        .font(.caption)
                        .foregroundStyle(AppTheme.onSurfaceVariant)

                    // Home Button
                    Button {
                        onDone()
                    } label: {
                        Text("ホームに戻る")
                    }
                    .buttonStyle(StitchPrimaryButtonStyle())
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
            }
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            startCountdown()
        }
    }

    private func startCountdown() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if countdown > 0 {
                countdown -= 1
            } else {
                timer.invalidate()
                onDone()
            }
        }
    }
}
