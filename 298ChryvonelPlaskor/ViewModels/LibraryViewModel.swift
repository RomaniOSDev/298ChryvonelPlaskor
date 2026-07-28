import Foundation
import Combine

enum InsightSegment: String, CaseIterable, Identifiable {
    case book = "Book"
    case theme = "Theme"
    case chronological = "Chronological"

    var id: String { rawValue }
}

struct InsightGroup: Identifiable {
    var id: String { name }
    var name: String
    var count: Int
}

final class LibraryViewModel: ObservableObject {
    @Published var segment: InsightSegment = .book
    @Published var selectedEvent: BookEvent?
    @Published var libraryMode: LibraryMode = .history

    enum LibraryMode: String, CaseIterable, Identifiable {
        case history = "History"
        case books = "Books"
        case characters = "Cast"
        case compare = "Compare"
        case insight = "Insight"
        var id: String { rawValue }
    }

    private let store: DataStore

    init(store: DataStore = .shared) {
        self.store = store
    }

    var historyEvents: [BookEvent] { store.historyEvents }
    var isEmpty: Bool { store.events.isEmpty }

    var insightGroups: [InsightGroup] {
        switch segment {
        case .book:
            return grouped(by: { $0.bookName })
        case .theme:
            return grouped(by: { $0.theme.isEmpty ? "General" : $0.theme })
        case .chronological:
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM yyyy"
            return grouped(by: { formatter.string(from: $0.date) })
        }
    }

    private func grouped(by key: (BookEvent) -> String) -> [InsightGroup] {
        let dict = Dictionary(grouping: store.events, by: key)
        return dict
            .map { InsightGroup(name: $0.key, count: $0.value.count) }
            .sorted { $0.count > $1.count }
    }

    func reorder(from source: IndexSet, to destination: Int) {
        store.reorderEvents(from: source, to: destination)
    }

    func delete(at offsets: IndexSet) {
        let ordered = historyEvents
        for index in offsets {
            store.deleteEvent(id: ordered[index].id)
        }
    }
}
