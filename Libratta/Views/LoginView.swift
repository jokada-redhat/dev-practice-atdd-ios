import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel
    var onLoginSuccess: () -> Void

    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    Spacer(minLength: 60)

                    // App Icon
                    Image(systemName: "books.vertical.circle.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(AppTheme.primary)

                    // App Name
                    Text("Libratta")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(AppTheme.primary)

                    // Subtitle
                    Text("図書管理システム")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.onSurfaceVariant)
                        .padding(.bottom, 16)

                    // Input Fields
                    VStack(spacing: 16) {
                        HStack(spacing: 12) {
                            Image(systemName: "envelope")
                                .foregroundStyle(AppTheme.outline)
                                .frame(width: 20)
                            TextField("メールアドレス", text: $viewModel.email)
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                                .accessibilityIdentifier("emailField")
                        }
                        .stitchInput()

                        HStack(spacing: 12) {
                            Image(systemName: "lock")
                                .foregroundStyle(AppTheme.outline)
                                .frame(width: 20)
                            SecureField("パスワード", text: $viewModel.password)
                                .textContentType(.password)
                                .accessibilityIdentifier("passwordField")
                        }
                        .stitchInput()
                    }
                    .padding(.horizontal, 32)

                    // Login Button
                    Button {
                        Task {
                            await viewModel.login()
                        }
                    } label: {
                        if viewModel.uiState == .loading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("ログイン")
                        }
                    }
                    .buttonStyle(StitchPrimaryButtonStyle())
                    .padding(.horizontal, 32)
                    .disabled(viewModel.uiState == .loading)
                    .accessibilityIdentifier("loginButton")

                    // Error Message
                    if case let .error(message) = viewModel.uiState {
                        Text(message)
                            .foregroundStyle(AppTheme.error)
                            .font(.subheadline)
                            .accessibilityIdentifier("errorMessage")
                    }

                    if viewModel.isDebugMode {
                        Text("デバッグモード: 認証情報が自動入力されています")
                            .font(.caption2)
                            .foregroundStyle(AppTheme.outline)
                    }

                    Spacer(minLength: 40)
                }
            }
        }
        .onChange(of: viewModel.uiState) { _, newValue in
            if case .success = newValue {
                onLoginSuccess()
            }
        }
    }
}
