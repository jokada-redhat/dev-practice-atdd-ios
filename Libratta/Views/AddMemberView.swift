import SwiftUI

struct AddMemberView: View {
    @ObservedObject var viewModel: AddMemberViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section("会員情報") {
                TextField("名前", text: $viewModel.name)
                    .accessibilityIdentifier("nameField")
                TextField("メールアドレス", text: $viewModel.email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .accessibilityIdentifier("emailField")
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
        .navigationTitle("会員登録")
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
