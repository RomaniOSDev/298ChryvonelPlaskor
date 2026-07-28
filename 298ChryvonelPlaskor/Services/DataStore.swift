import Foundation
import Combine
import SwiftUI

final class DataStore: ObservableObject {
    static let shared = DataStore()

    @Published var events: [BookEvent] = []
    @Published var books: [BookRecord] = []
    @Published var stats: UserStats = .empty
    @Published var hasCompletedOnboarding: Bool
    @Published var bannerAchievement: AchievementID?
    @Published var soundEnabled: Bool
    @Published var hapticEnabled: Bool
    @Published var appearance: AppAppearance
    @Published var fontSize: AppFontSize

    private let eventsKey = "book_events"
    private let booksKey = "book_records"
    private let statsKey = "user_stats"
    private let onboardingKey = "has_completed_onboarding"
    private let appearanceKey = "app_appearance"
    private let fontSizeKey = "app_font_size"
    private let defaults = UserDefaults.standard

    private init() {
        hasCompletedOnboarding = defaults.bool(forKey: onboardingKey)
        soundEnabled = SoundService.isEnabled
        hapticEnabled = HapticService.isEnabled
        if let raw = defaults.string(forKey: appearanceKey),
           let value = AppAppearance(rawValue: raw) {
            appearance = value
        } else {
            appearance = .dark
        }
        if let raw = defaults.string(forKey: fontSizeKey),
           let value = AppFontSize(rawValue: raw) {
            fontSize = value
        } else {
            fontSize = .medium
        }
        load()
        syncBooksFromEvents()
    }

    func setSoundEnabled(_ enabled: Bool) {
        soundEnabled = enabled
        SoundService.isEnabled = enabled
    }

    func setHapticEnabled(_ enabled: Bool) {
        hapticEnabled = enabled
        HapticService.isEnabled = enabled
    }

    func setAppearance(_ value: AppAppearance) {
        appearance = value
        defaults.set(value.rawValue, forKey: appearanceKey)
    }

    func setFontSize(_ value: AppFontSize) {
        fontSize = value
        defaults.set(value.rawValue, forKey: fontSizeKey)
    }

    func completeOnboarding(seedDemo: Bool = false) {
        hasCompletedOnboarding = true
        defaults.set(true, forKey: onboardingKey)
        if seedDemo && events.isEmpty {
            seedDemoChronicle()
        }
        registerSession()
    }

    func load() {
        if let data = defaults.data(forKey: eventsKey),
           let decoded = try? JSONDecoder().decode([BookEvent].self, from: data) {
            events = decoded
        }
        if let data = defaults.data(forKey: booksKey),
           let decoded = try? JSONDecoder().decode([BookRecord].self, from: data) {
            books = decoded
        }
        if let data = defaults.data(forKey: statsKey),
           let decoded = try? JSONDecoder().decode(UserStats.self, from: data) {
            stats = decoded
        }
    }

    func save() {
        if let data = try? JSONEncoder().encode(events) {
            defaults.set(data, forKey: eventsKey)
        }
        if let data = try? JSONEncoder().encode(books) {
            defaults.set(data, forKey: booksKey)
        }
        if let data = try? JSONEncoder().encode(stats) {
            defaults.set(data, forKey: statsKey)
        }
    }

    func addEvent(_ event: BookEvent, genreHint: String? = nil) {
        var next = event
        next.sortOrder = events.count
        events.append(next)
        upsertBook(named: next.bookName, genreHint: genreHint)
        stats.itemsCreated += 1
        registerActivity()
        evaluateAchievements()
        save()
        HapticService.success()
        SoundService.success()
    }

    func updateEvent(_ event: BookEvent) {
        guard let index = events.firstIndex(where: { $0.id == event.id }) else { return }
        let oldName = events[index].bookName
        events[index] = event
        upsertBook(named: event.bookName)
        if oldName != event.bookName {
            pruneOrphanBooks()
        }
        registerActivity()
        save()
        HapticService.light()
        SoundService.tap()
    }

    func deleteEvent(id: UUID) {
        events.removeAll { $0.id == id }
        for i in events.indices {
            events[i].links.removeAll { $0.targetEventID == id }
        }
        pruneOrphanBooks()
        save()
        HapticService.warning()
        SoundService.tap()
    }

    func reorderEvents(from source: IndexSet, to destination: Int) {
        var ordered = events.sorted { $0.sortOrder < $1.sortOrder }
        ordered.move(fromOffsets: source, toOffset: destination)
        for (index, _) in ordered.enumerated() {
            ordered[index].sortOrder = index
        }
        events = ordered
        save()
        HapticService.light()
    }

    func updateBook(_ book: BookRecord) {
        guard let index = books.firstIndex(where: { $0.id == book.id }) else { return }
        let oldName = books[index].name
        books[index] = book
        if oldName != book.name {
            for i in events.indices where events[i].bookName == oldName {
                events[i].bookName = book.name
            }
        }
        save()
        HapticService.light()
        SoundService.tap()
    }

    func registerSession() {
        stats.sessionsCompleted += 1
        registerActivity()
        evaluateAchievements()
        save()
    }

    func resetAllData() {
        events = []
        books = []
        stats = .empty
        defaults.removeObject(forKey: eventsKey)
        defaults.removeObject(forKey: booksKey)
        defaults.removeObject(forKey: statsKey)
        bannerAchievement = nil
        HapticService.warning()
        SoundService.tap()
    }

    func seedDemoChronicle() {
        let day: (Int) -> Date = { offset in
            Calendar.current.date(byAdding: .day, value: offset, to: Date()) ?? Date()
        }
        let introID = UUID()
        let turnID = UUID()
        let climaxID = UUID()

        let intro = BookEvent(
            id: introID,
            title: "Arrival in Emberford",
            description: "The traveler reaches the fog-bound town and meets Mira, the mapkeeper.",
            date: day(-14),
            tags: ["Mira", "Emberford", "arrival"],
            bookName: "The Golden Quill",
            theme: "Setting",
            sortOrder: 0,
            quotes: [
                Quote(text: "Fog is only a curtain for those who refuse to look.", attribution: "Mira")
            ]
        )
        let turn = BookEvent(
            id: turnID,
            title: "The sealed letter",
            description: "A wax-sealed letter names the traitor in the guild.",
            date: day(-7),
            tags: ["letter", "guild", "Mira"],
            bookName: "The Golden Quill",
            theme: "Plot",
            sortOrder: 1,
            links: [EventLink(targetEventID: introID, type: .causedBy)]
        )
        let climax = BookEvent(
            id: climaxID,
            title: "Confrontation at the quay",
            description: "Mira and the traveler face the guildmaster under lantern light.",
            date: day(-1),
            tags: ["Mira", "guildmaster", "climax"],
            bookName: "The Golden Quill",
            theme: "Character",
            sortOrder: 2,
            links: [
                EventLink(targetEventID: turnID, type: .causedBy),
                EventLink(targetEventID: introID, type: .flashback)
            ],
            quotes: [
                Quote(text: "Every map begins with a lie we agree to believe.", attribution: "Guildmaster")
            ]
        )

        events = [intro, turn, climax]
        books = [
            BookRecord(name: "The Golden Quill", genre: "Fantasy", notes: "Sample chronicle from onboarding.")
        ]
        stats.itemsCreated = events.count
        registerActivity()
        evaluateAchievements()
        save()
    }

    private func upsertBook(named name: String, genreHint: String? = nil) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalName = trimmed.isEmpty ? "Untitled Book" : trimmed
        if let index = books.firstIndex(where: { $0.name.caseInsensitiveCompare(finalName) == .orderedSame }) {
            if let genreHint, books[index].genre == "General", genreHint != "General" {
                books[index].genre = genreHint
            }
            return
        }
        books.append(BookRecord(name: finalName, genre: genreHint ?? "General"))
    }

    private func syncBooksFromEvents() {
        for event in events {
            upsertBook(named: event.bookName)
        }
        pruneOrphanBooks()
        save()
    }

    private func pruneOrphanBooks() {
        let names = Set(events.map { $0.bookName.lowercased() })
        books.removeAll { !names.contains($0.name.lowercased()) }
    }

    private func registerActivity() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        if let last = stats.lastActiveDate {
            let lastDay = calendar.startOfDay(for: last)
            let days = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
            if days == 1 {
                stats.streakDays += 1
            } else if days > 1 {
                stats.streakDays = 1
            }
        } else {
            stats.streakDays = 1
        }
        stats.lastActiveDate = today
    }

    private func evaluateAchievements() {
        for achievement in AchievementID.allCases {
            let already = stats.unlockedAchievements.contains { $0.achievementID == achievement }
            if !already && achievement.isUnlocked(stats: stats) {
                let unlocked = UnlockedAchievement(achievementID: achievement, unlockedAt: Date())
                stats.unlockedAchievements.append(unlocked)
                bannerAchievement = achievement
                HapticService.success()
                SoundService.achievement()
            }
        }
    }

    var chronologicalEvents: [BookEvent] {
        events.sorted { $0.date < $1.date }
    }

    var historyEvents: [BookEvent] {
        events.sorted { $0.sortOrder < $1.sortOrder }
    }

    func filteredChronological(_ filter: EventFilter) -> [BookEvent] {
        chronologicalEvents.filter { filter.matches($0) }
    }

    func filteredHistory(_ filter: EventFilter) -> [BookEvent] {
        historyEvents.filter { filter.matches($0) }
    }

    func events(forBook name: String) -> [BookEvent] {
        chronologicalEvents.filter { $0.bookName.caseInsensitiveCompare(name) == .orderedSame }
    }

    func event(id: UUID) -> BookEvent? {
        events.first { $0.id == id }
    }

    var allBookNames: [String] {
        Array(Set(events.map(\.bookName))).sorted()
    }

    var allThemes: [String] {
        Array(Set(events.map(\.theme))).sorted()
    }

    var allTags: [String] {
        Array(Set(events.flatMap(\.tags))).sorted()
    }

    var characters: [CharacterEntry] {
        var map: [String: (books: Set<String>, events: Set<UUID>)] = [:]
        for event in events where event.theme == "Character" || event.tags.contains(where: { !$0.isEmpty }) {
            let names: [String]
            if event.theme == "Character" {
                names = event.tags.isEmpty ? [event.title] : event.tags
            } else {
                // Only treat Capitalized multi-use tags lightly: Character theme is primary source
                names = []
            }
            for name in names {
                let key = name.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !key.isEmpty else { continue }
                var entry = map[key.lowercased()] ?? (books: [], events: [])
                entry.books.insert(event.bookName)
                entry.events.insert(event.id)
                map[key.lowercased()] = entry
            }
        }
        // Also harvest tags named like people from Character-themed events only (already done)
        return map.map { key, value in
            let display = events
                .flatMap(\.tags)
                .first { $0.lowercased() == key }
                ?? events.first { $0.theme == "Character" && $0.title.lowercased() == key }?.title
                ?? key.capitalized
            return CharacterEntry(
                name: display,
                eventCount: value.events.count,
                books: value.books.sorted(),
                eventIDs: Array(value.events)
            )
        }
        .sorted { $0.eventCount > $1.eventCount }
    }

    var bookComparisons: [BookComparison] {
        let calendar = Calendar.current
        return allBookNames.map { name in
            let bookEvents = events(forBook: name)
            let themes = Dictionary(grouping: bookEvents, by: \.theme).mapValues(\.count)
            let dominant = themes.max { $0.value < $1.value }?.key ?? "General"
            let quotes = bookEvents.reduce(0) { $0 + $1.quotes.count }
            let dates = bookEvents.map(\.date).sorted()
            let span: Int
            if let first = dates.first, let last = dates.last {
                span = max(calendar.dateComponents([.day], from: first, to: last).day ?? 0, 0)
            } else {
                span = 0
            }
            let weeks = max(Double(span) / 7.0, 1.0 / 7.0)
            let genre = books.first { $0.name.caseInsensitiveCompare(name) == .orderedSame }?.genre ?? "General"
            return BookComparison(
                name: name,
                genre: genre,
                eventCount: bookEvents.count,
                quoteCount: quotes,
                dominantTheme: dominant,
                densityPerWeek: Double(bookEvents.count) / weeks,
                spanDays: span
            )
        }
        .sorted { $0.eventCount > $1.eventCount }
    }

    func progress(forBook name: String) -> Double {
        let count = events(forBook: name).count
        return min(1, Double(count) / 10.0)
    }
}
