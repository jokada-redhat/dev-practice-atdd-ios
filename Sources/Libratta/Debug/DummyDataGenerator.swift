import Foundation

public final class DummyDataGenerator: Sendable {
    private let memberRepository: MemberRepository
    private let bookRepository: BookRepository
    private let loanRepository: LoanRepository

    public init(
        memberRepository: MemberRepository,
        bookRepository: BookRepository,
        loanRepository: LoanRepository
    ) {
        self.memberRepository = memberRepository
        self.bookRepository = bookRepository
        self.loanRepository = loanRepository
    }

    public func generate() {
        generateMembers()
        generateBooks()
        generateLoans()
    }

    private func generateMembers() {
        let members = [
            Member(id: "DA-0001", name: "Taro Yamada", email: "taro@example.com"),
            Member(id: "DA-0002", name: "Hanako Suzuki", email: "hanako@example.com"),
            Member(id: "DA-0003", name: "Marcus Thorne", email: "marcus@example.com"),
            Member(id: "DA-0004", name: "Julian Chen", email: "julian@example.com"),
            Member(id: "DA-0005", name: "Elena Vasquez", email: "elena@example.com"),
            Member(id: "DA-0006", name: "Kenji Tanaka", email: "kenji@example.com"),
            Member(id: "DA-0007", name: "Sophia Kim", email: "sophia@example.com"),
            Member(id: "DA-0008", name: "Raj Patel", email: "raj@example.com"),
            Member(id: "DA-0009", name: "Yuki Nakamura", email: "yuki@example.com"),
            Member(id: "DA-0010", name: "Oliver Schmidt", email: "oliver@example.com"),
        ]
        for member in members {
            try? memberRepository.save(member)
        }
    }

    private func generateBooks() {
        let books = [
            Book(id: "B-001", title: "The Infinite Library", author: "Jorge Luis Borges", isbn: "978-0142437889", publicationYear: 1941),
            Book(id: "B-002", title: "Neuromancer", author: "William Gibson", isbn: "978-0441569595", publicationYear: 1984),
            Book(id: "B-003", title: "Foundation", author: "Isaac Asimov", isbn: "978-0553293357", publicationYear: 1951),
            Book(id: "B-004", title: "The Left Hand of Darkness", author: "Ursula K. Le Guin", isbn: "978-0441478125", publicationYear: 1969),
            Book(id: "B-005", title: "Dune", author: "Frank Herbert", isbn: "978-0441172719", publicationYear: 1965),
            Book(id: "B-006", title: "Snow Crash", author: "Neal Stephenson", isbn: "978-0553380958", publicationYear: 1992),
            Book(id: "B-007", title: "The Dispossessed", author: "Ursula K. Le Guin", isbn: "978-0061054884", publicationYear: 1974),
            Book(id: "B-008", title: "Hyperion", author: "Dan Simmons", isbn: "978-0553283686", publicationYear: 1989),
            Book(id: "B-009", title: "The Stars My Destination", author: "Alfred Bester", isbn: "978-0679767800", publicationYear: 1956),
            Book(id: "B-010", title: "Childhood's End", author: "Arthur C. Clarke", isbn: "978-0345347954", publicationYear: 1953),
        ]
        for book in books {
            try? bookRepository.save(book)
        }
    }

    private func generateLoans() {
        let borrowings: [(memberId: String, bookId: String)] = [
            ("DA-0001", "B-002"),
            ("DA-0003", "B-005"),
            ("DA-0004", "B-008"),
        ]
        for borrow in borrowings {
            let loan = Loan(memberId: borrow.memberId, bookId: borrow.bookId)
            try? loanRepository.save(loan)
            try? bookRepository.updateStatus(id: borrow.bookId, status: .borrowed)
            if let member = memberRepository.findById(borrow.memberId) {
                try? memberRepository.updateLoanCount(id: member.id, loanCount: member.loanCount + 1)
            }
        }
    }
}
