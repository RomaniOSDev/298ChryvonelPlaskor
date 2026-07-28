import Foundation

struct BookEvent: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var description: String
    var date: Date
    var tags: [String]
    var bookName: String
    var theme: String
    var sortOrder: Int
    var links: [EventLink]
    var quotes: [Quote]

    init(
        id: UUID = UUID(),
        title: String,
        description: String = "",
        date: Date = Date(),
        tags: [String] = [],
        bookName: String = "Untitled Book",
        theme: String = "General",
        sortOrder: Int = 0,
        links: [EventLink] = [],
        quotes: [Quote] = []
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.date = date
        self.tags = tags
        self.bookName = bookName
        self.theme = theme
        self.sortOrder = sortOrder
        self.links = links
        self.quotes = quotes
    }

    enum CodingKeys: String, CodingKey {
        case id, title, description, date, tags, bookName, theme, sortOrder, links, quotes
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        date = try container.decodeIfPresent(Date.self, forKey: .date) ?? Date()
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
        bookName = try container.decodeIfPresent(String.self, forKey: .bookName) ?? "Untitled Book"
        theme = try container.decodeIfPresent(String.self, forKey: .theme) ?? "General"
        sortOrder = try container.decodeIfPresent(Int.self, forKey: .sortOrder) ?? 0
        links = try container.decodeIfPresent([EventLink].self, forKey: .links) ?? []
        quotes = try container.decodeIfPresent([Quote].self, forKey: .quotes) ?? []
    }
}

struct EventFilter: Equatable {
    var query: String = ""
    var bookName: String = "All"
    var theme: String = "All"
    var tag: String = "All"
    var dateFrom: Date?
    var dateTo: Date?

    var isActive: Bool {
        !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || bookName != "All"
            || theme != "All"
            || tag != "All"
            || dateFrom != nil
            || dateTo != nil
    }

    func matches(_ event: BookEvent) -> Bool {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !q.isEmpty {
            let haystack = [
                event.title,
                event.description,
                event.bookName,
                event.theme,
                event.tags.joined(separator: " "),
                event.quotes.map(\.text).joined(separator: " ")
            ].joined(separator: " ").lowercased()
            if !haystack.contains(q) { return false }
        }
        if bookName != "All", event.bookName != bookName { return false }
        if theme != "All", event.theme != theme { return false }
        if tag != "All", !event.tags.contains(where: { $0.caseInsensitiveCompare(tag) == .orderedSame }) {
            return false
        }
        let calendar = Calendar.current
        if let from = dateFrom {
            let start = calendar.startOfDay(for: from)
            if event.date < start { return false }
        }
        if let to = dateTo {
            let end = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: to)) ?? to
            if event.date >= end { return false }
        }
        return true
    }
}
