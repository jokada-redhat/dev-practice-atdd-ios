import SwiftUI

struct LoanConfirmationView: View {
    let memberName: String
    let bookTitle: String
    var onDone: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.green)

            Text("貸し出し完了")
                .font(.title)
                .fontWeight(.bold)

            VStack(spacing: 12) {
                HStack {
                    Text("会員")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(memberName)
                        .fontWeight(.medium)
                }
                Divider()
                HStack {
                    Text("書籍")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(bookTitle)
                        .fontWeight(.medium)
                }
            }
            .padding()
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
            .padding(.horizontal, 32)

            Spacer()

            Button {
                onDone()
            } label: {
                Text("トップへ戻る")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
        .navigationBarBackButtonHidden()
    }
}
