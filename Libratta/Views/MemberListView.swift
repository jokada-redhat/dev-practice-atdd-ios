import SwiftUI

struct MemberListView: View {
    @ObservedObject var viewModel: MemberListViewModel
    var onMemberSelected: (Member) -> Void
    @State private var showAddMember = false
    var addMemberViewModelFactory: () -> AddMemberViewModel

    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()

            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.members) { member in
                        MemberCard(member: member)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                onMemberSelected(member)
                            }
                            .accessibilityIdentifier("memberCard_\(member.id)")
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
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
                Text("ID: \(member.id)")
                    .font(.caption2)
                    .foregroundStyle(AppTheme.onSurfaceVariant)
                    .textCase(.uppercase)

                Text(member.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.onSurface)

                if member.loanCount > 0 {
                    Text("\(member.loanCount)冊 貸し出し中")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(AppTheme.primary)
                        .textCase(.uppercase)
                } else {
                    Text("貸し出しなし")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(AppTheme.primary)
                        .textCase(.uppercase)
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(AppTheme.onSurfaceVariant)
        }
        .padding(20)
        .background(AppTheme.surfaceContainerLowest)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.bottom, 20)
    }
}
