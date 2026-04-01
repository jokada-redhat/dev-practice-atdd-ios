import SwiftUI

struct MemberListView: View {
    @ObservedObject var viewModel: MemberListViewModel
    var onMemberSelected: (Member) -> Void
    @State private var showAddMember = false
    var addMemberViewModelFactory: () -> AddMemberViewModel

    var body: some View {
        List {
            ForEach(viewModel.members) { member in
                MemberCard(member: member)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onMemberSelected(member)
                    }
                    .accessibilityIdentifier("memberCard_\(member.id)")
            }
        }
        .searchable(text: $viewModel.searchQuery, prompt: "名前・メール・IDで検索")
        .onChange(of: viewModel.searchQuery) { _, _ in
            viewModel.loadMembers()
        }
        .navigationTitle("会員一覧")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAddMember = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddMember) {
            viewModel.loadMembers()
        } content: {
            NavigationStack {
                AddMemberView(viewModel: addMemberViewModelFactory())
            }
        }
        .onAppear {
            viewModel.loadMembers()
        }
    }
}

struct MemberCard: View {
    let member: Member

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(member.name)
                    .font(.headline)
                Text(member.email)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("ID: \(member.id)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            Spacer()
            if member.loanCount > 0 {
                Text("\(member.loanCount)冊")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.blue.opacity(0.1))
                    .foregroundStyle(.blue)
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 4)
    }
}
