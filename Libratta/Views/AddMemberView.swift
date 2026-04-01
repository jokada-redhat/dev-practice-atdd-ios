import SwiftUI

struct AddMemberView: View {
    @ObservedObject var viewModel: AddMemberViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    // Form Card
                    VStack(spacing: 16) {
                        StitchFormField(label: "会員ID", icon: "magnifyingglass") {
                            TextField("", text: .constant(""))
                                .disabled(true)
                        }

                        Toggle("自動生成する", isOn: .constant(true))
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.onSurface)
                            .disabled(true)

                        StitchFormField(label: "氏名", icon: "person") {
                            TextField("", text: $viewModel.name)
                                .accessibilityIdentifier("nameField")
                        }
                    }
                    .padding(24)
                    .background(AppTheme.surfaceContainerLow)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundStyle(AppTheme.error)
                            .font(.subheadline)
                    }

                    Button {
                        viewModel.register()
                    } label: {
                        HStack {
                            Text("登録する")
                            Image(systemName: "plus")
                        }
                    }
                    .buttonStyle(StitchPrimaryButtonStyle())
                    .accessibilityIdentifier("registerButton")
                    .padding(.top, 8)
                }
                .padding(24)
            }
        }
        .navigationTitle("会員の新規登録")
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
