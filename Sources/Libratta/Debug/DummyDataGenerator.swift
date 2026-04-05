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
            Member(id: "DA-0001", name: "山田太郎"),
            Member(id: "DA-0002", name: "佐藤花子"),
            Member(id: "DA-0003", name: "鈴木一郎"),
            Member(id: "DA-0004", name: "田中美咲"),
            Member(id: "DA-0005", name: "高橋健太"),
            Member(id: "DA-0006", name: "伊藤由美"),
            Member(id: "DA-0007", name: "渡辺翔太"),
            Member(id: "DA-0008", name: "中村あかり"),
            Member(id: "DA-0009", name: "小林大輔"),
            Member(id: "DA-0010", name: "加藤さくら"),
            Member(id: "DA-0011", name: "吉田拓海"),
            Member(id: "DA-0012", name: "山口真理"),
            Member(id: "DA-0013", name: "松本悠人"),
            Member(id: "DA-0014", name: "井上凛"),
            Member(id: "DA-0015", name: "木村蓮"),
            Member(id: "DA-0016", name: "林美優"),
            Member(id: "DA-0017", name: "清水陽太"),
            Member(id: "DA-0018", name: "森本結衣"),
            Member(id: "DA-0019", name: "池田颯太"),
            Member(id: "DA-0020", name: "橋本琴音")
        ]
        for member in members {
            try? memberRepository.save(member)
        }
    }

    // swiftlint:disable function_body_length
    private func generateBooks() {
        let books = [
            // 日本文学
            Book(id: "B-001", title: "吾輩は猫である",
                 author: "夏目漱石", isbn: "978-4-10-101001-5", publicationYear: 1905),
            Book(id: "B-002", title: "坊っちゃん",
                 author: "夏目漱石", isbn: "978-4-10-101002-2", publicationYear: 1906),
            Book(id: "B-003", title: "人間失格",
                 author: "太宰治", isbn: "978-4-10-101003-9", publicationYear: 1948),
            Book(id: "B-004", title: "走れメロス",
                 author: "太宰治", isbn: "978-4-10-101004-6", publicationYear: 1940),
            Book(id: "B-005", title: "雪国",
                 author: "川端康成", isbn: "978-4-10-101005-3", publicationYear: 1937),
            Book(id: "B-006", title: "伊豆の踊子",
                 author: "川端康成", isbn: "978-4-10-101006-0", publicationYear: 1926),
            Book(id: "B-007", title: "羅生門",
                 author: "芥川龍之介", isbn: "978-4-10-101007-7", publicationYear: 1915),
            Book(id: "B-008", title: "蜘蛛の糸",
                 author: "芥川龍之介", isbn: "978-4-10-101008-4", publicationYear: 1918),
            Book(id: "B-009", title: "ノルウェイの森",
                 author: "村上春樹", isbn: "978-4-10-101009-1", publicationYear: 1987),
            Book(id: "B-010", title: "海辺のカフカ",
                 author: "村上春樹", isbn: "978-4-10-101010-7", publicationYear: 2002),
            // SF・ファンタジー
            Book(id: "B-011", title: "銀河鉄道の夜",
                 author: "宮沢賢治", isbn: "978-4-10-102001-4", publicationYear: 1934),
            Book(id: "B-012", title: "時をかける少女",
                 author: "筒井康隆", isbn: "978-4-10-102002-1", publicationYear: 1967),
            Book(id: "B-013", title: "新世界より",
                 author: "貴志祐介", isbn: "978-4-10-102003-8", publicationYear: 2008),
            Book(id: "B-014", title: "ハーモニー",
                 author: "伊藤計劃", isbn: "978-4-10-102004-5", publicationYear: 2008),
            Book(id: "B-015", title: "虐殺器官",
                 author: "伊藤計劃", isbn: "978-4-10-102005-2", publicationYear: 2007),
            Book(id: "B-016", title: "デューン 砂の惑星",
                 author: "フランク・ハーバート", isbn: "978-4-15-012001-3", publicationYear: 1965),
            Book(id: "B-017", title: "ニューロマンサー",
                 author: "ウィリアム・ギブスン", isbn: "978-4-15-012002-0", publicationYear: 1984),
            Book(id: "B-018", title: "ファウンデーション",
                 author: "アイザック・アシモフ", isbn: "978-4-15-012003-7", publicationYear: 1951),
            Book(id: "B-019", title: "2001年宇宙の旅",
                 author: "アーサー・C・クラーク", isbn: "978-4-15-012004-4", publicationYear: 1968),
            Book(id: "B-020", title: "アンドロイドは電気羊の夢を見るか?",
                 author: "フィリップ・K・ディック", isbn: "978-4-15-012005-1", publicationYear: 1968),
            // ミステリー
            Book(id: "B-021", title: "容疑者Xの献身",
                 author: "東野圭吾", isbn: "978-4-16-103001-3", publicationYear: 2005),
            Book(id: "B-022", title: "白夜行",
                 author: "東野圭吾", isbn: "978-4-16-103002-0", publicationYear: 1999),
            Book(id: "B-023", title: "模倣犯",
                 author: "宮部みゆき", isbn: "978-4-16-103003-7", publicationYear: 2001),
            Book(id: "B-024", title: "火車",
                 author: "宮部みゆき", isbn: "978-4-16-103004-4", publicationYear: 1992),
            Book(id: "B-025", title: "十角館の殺人",
                 author: "綾辻行人", isbn: "978-4-16-103005-1", publicationYear: 1987),
            Book(id: "B-026", title: "占星術殺人事件",
                 author: "島田荘司", isbn: "978-4-16-103006-8", publicationYear: 1981),
            Book(id: "B-027", title: "殺戮にいたる病",
                 author: "我孫子武丸", isbn: "978-4-16-103007-5", publicationYear: 1992),
            Book(id: "B-028", title: "すべてがFになる",
                 author: "森博嗣", isbn: "978-4-16-103008-2", publicationYear: 1996),
            Book(id: "B-029", title: "告白",
                 author: "湊かなえ", isbn: "978-4-16-103009-9", publicationYear: 2008),
            Book(id: "B-030", title: "氷菓",
                 author: "米澤穂信", isbn: "978-4-16-103010-5", publicationYear: 2001),
            // 海外文学
            Book(id: "B-031", title: "星の王子さま",
                 author: "サン=テグジュペリ", isbn: "978-4-10-104001-2", publicationYear: 1943),
            Book(id: "B-032", title: "変身",
                 author: "フランツ・カフカ", isbn: "978-4-10-104002-9", publicationYear: 1915),
            Book(id: "B-033", title: "老人と海",
                 author: "アーネスト・ヘミングウェイ", isbn: "978-4-10-104003-6", publicationYear: 1952),
            Book(id: "B-034", title: "異邦人",
                 author: "アルベール・カミュ", isbn: "978-4-10-104004-3", publicationYear: 1942),
            Book(id: "B-035", title: "グレート・ギャツビー",
                 author: "F・スコット・フィッツジェラルド", isbn: "978-4-10-104005-0", publicationYear: 1925),
            Book(id: "B-036", title: "1984年",
                 author: "ジョージ・オーウェル", isbn: "978-4-10-104006-7", publicationYear: 1949),
            Book(id: "B-037", title: "ライ麦畑でつかまえて",
                 author: "J・D・サリンジャー", isbn: "978-4-10-104007-4", publicationYear: 1951),
            Book(id: "B-038", title: "罪と罰",
                 author: "フョードル・ドストエフスキー", isbn: "978-4-10-104008-1", publicationYear: 1866),
            Book(id: "B-039", title: "百年の孤独",
                 author: "ガブリエル・ガルシア=マルケス", isbn: "978-4-10-104009-8", publicationYear: 1967),
            Book(id: "B-040", title: "車輪の下",
                 author: "ヘルマン・ヘッセ", isbn: "978-4-10-104010-4", publicationYear: 1906),
            // ノンフィクション・ビジネス
            Book(id: "B-041", title: "サピエンス全史",
                 author: "ユヴァル・ノア・ハラリ", isbn: "978-4-309-22671-2", publicationYear: 2011),
            Book(id: "B-042", title: "ファクトフルネス",
                 author: "ハンス・ロスリング", isbn: "978-4-532-17621-5", publicationYear: 2018),
            Book(id: "B-043", title: "銃・病原菌・鉄",
                 author: "ジャレド・ダイアモンド", isbn: "978-4-794-21005-7", publicationYear: 1997),
            Book(id: "B-044", title: "思考の整理学",
                 author: "外山滋比古", isbn: "978-4-480-02047-0", publicationYear: 1983),
            Book(id: "B-045", title: "嫌われる勇気",
                 author: "岸見一郎・古賀史健", isbn: "978-4-478-02581-9", publicationYear: 2013),
            Book(id: "B-046", title: "7つの習慣",
                 author: "スティーブン・R・コヴィー", isbn: "978-4-863-40010-4", publicationYear: 1989),
            Book(id: "B-047", title: "影響力の武器",
                 author: "ロバート・B・チャルディーニ", isbn: "978-4-416-70601-5", publicationYear: 1984),
            Book(id: "B-048", title: "ゼロ・トゥ・ワン",
                 author: "ピーター・ティール", isbn: "978-4-14-081695-0", publicationYear: 2014),
            Book(id: "B-049", title: "イシューからはじめよ",
                 author: "安宅和人", isbn: "978-4-862-76088-5", publicationYear: 2010),
            Book(id: "B-050", title: "FACTFULNESS",
                 author: "ハンス・ロスリング", isbn: "978-4-532-32211-6", publicationYear: 2019)
        ]
        for book in books {
            try? bookRepository.save(book)
        }
    }
    // swiftlint:enable function_body_length

    private struct LoanSeed {
        let memberId: String
        let bookId: String
        let daysAgo: Int
    }

    private func generateLoans() {
        let now = Date()
        let calendar = Calendar.current
        let borrowings: [LoanSeed] = [
            LoanSeed(memberId: "DA-0001", bookId: "B-003", daysAgo: 5),
            LoanSeed(memberId: "DA-0001", bookId: "B-009", daysAgo: 3),
            LoanSeed(memberId: "DA-0002", bookId: "B-017", daysAgo: 10),
            LoanSeed(memberId: "DA-0002", bookId: "B-021", daysAgo: 7),
            LoanSeed(memberId: "DA-0003", bookId: "B-031", daysAgo: 12),
            LoanSeed(memberId: "DA-0004", bookId: "B-036", daysAgo: 2),
            LoanSeed(memberId: "DA-0004", bookId: "B-041", daysAgo: 1),
            LoanSeed(memberId: "DA-0005", bookId: "B-045", daysAgo: 8),
            LoanSeed(memberId: "DA-0006", bookId: "B-012", daysAgo: 4),
            LoanSeed(memberId: "DA-0006", bookId: "B-025", daysAgo: 6)
        ]
        for seed in borrowings {
            let borrowedDate = calendar.date(byAdding: .day, value: -seed.daysAgo, to: now) ?? now
            let loan = Loan(memberId: seed.memberId, bookId: seed.bookId, borrowedDate: borrowedDate)
            try? loanRepository.save(loan)
        }
    }
}
