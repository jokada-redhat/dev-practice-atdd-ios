import SwiftUI

struct AddBookView: View {
    @ObservedObject var viewModel: AddBookViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section("書籍情報") {
                TextField("タイトル", text: $viewModel.title)
                    .accessibilityIdentifier("titleField")
                TextField("著者", text: $viewModel.author)
                    .accessibilityIdentifier("authorField")
                TextField("ISBN", text: $viewModel.isbn)
                    .accessibilityIdentifier("isbnField")
                TextField("出版年", text: $viewModel.publicationYear)
                    .keyboardType(.numberPad)
                    .accessibilityIdentifier("yearField")
            }

            if let error = viewModel.errorMessage {
                Section {
                    Text(error)
                        .foregroundStyle(.red)
                }
            }

            Section {
                Button("登録") {
                    viewModel.register()
                }
                .accessibilityIdentifier("registerButton")
            }
        }
        .navigationTitle("書籍登録")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("キャンセル") {
                    dismiss()
                }
            }
        }
        .onChange(of: viewModel.isSuccess) { _, success in
            if success { dismiss() }
        }
    }
}
