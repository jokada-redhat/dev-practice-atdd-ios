import SwiftUI

struct AddBookView: View {
    @ObservedObject var viewModel: AddBookViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    StitchFormField(label: "タイトル", icon: "textformat") {
                        TextField("書籍のタイトルを入力", text: $viewModel.title)
                            .accessibilityIdentifier("titleField")
                    }

                    StitchFormField(label: "著者", icon: "person") {
                        TextField("著者名を入力", text: $viewModel.author)
                            .accessibilityIdentifier("authorField")
                    }

                    StitchFormField(label: "ISBN-13", icon: "barcode") {
                        TextField("例: 978-0000000000", text: $viewModel.isbn)
                            .accessibilityIdentifier("isbnField")
                    }

                    StitchFormField(label: "出版年", icon: "calendar") {
                        TextField("例: 2024", text: $viewModel.publicationYear)
                            .keyboardType(.numberPad)
                            .accessibilityIdentifier("yearField")
                    }

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundStyle(AppTheme.error)
                            .font(.subheadline)
                    }

                    Button {
                        viewModel.register()
                    } label: {
                        HStack {
                            Image(systemName: "book.closed")
                            Text("登録する")
                        }
                    }
                    .buttonStyle(StitchPrimaryButtonStyle())
                    .accessibilityIdentifier("registerButton")
                    .padding(.top, 16)
                }
                .padding(24)
            }
        }
        .navigationTitle("書籍の新規登録")
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

struct StitchFormField<Content: View>: View {
    let label: String
    let icon: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(AppTheme.onSurfaceVariant)

            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundStyle(AppTheme.outline)
                    .frame(width: 20)
                content
            }
            .stitchInput()
        }
    }
}
