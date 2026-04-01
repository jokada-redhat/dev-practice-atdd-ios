import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel
    var onLoginSuccess: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Libratta")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("図書館管理システム")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(spacing: 16) {
                TextField("メールアドレス", text: $viewModel.email)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .accessibilityIdentifier("emailField")

                SecureField("パスワード", text: $viewModel.password)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.password)
                    .accessibilityIdentifier("passwordField")
            }
            .padding(.horizontal, 32)

            if case let .error(message) = viewModel.uiState {
                Text(message)
                    .foregroundStyle(.red)
                    .font(.caption)
                    .accessibilityIdentifier("errorMessage")
            }

            Button {
                Task {
                    await viewModel.login()
                }
            } label: {
                if viewModel.uiState == .loading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("ログイン")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 32)
            .disabled(viewModel.uiState == .loading)
            .accessibilityIdentifier("loginButton")

            if viewModel.isDebugMode {
                Text("デバッグモード: 認証情報が自動入力されています")
                    .font(.caption2)
                    .foregroundStyle(.orange)
            }

            Spacer()
        }
        .onChange(of: viewModel.uiState) { _, newValue in
            if case .success = newValue {
                onLoginSuccess()
            }
        }
    }
}
