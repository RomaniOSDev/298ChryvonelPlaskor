import SwiftUI

struct LibraryView: View {
    @ObservedObject var store: DataStore
    @State private var libraryMode: LibraryViewModel.LibraryMode = .history
    @State private var segment: InsightSegment = .book
    @State private var selectedEvent: BookEvent?
    @State private var selectedBook: BookRecord?
    @State private var filter = EventFilter()
    @State private var selectedCharacter: CharacterEntry?

    private var historyEvents: [BookEvent] { store.filteredHistory(filter) }

    private var insightGroups: [InsightGroup] {
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

    var body: some View {
        AppBackground {
            VStack(spacing: 0) {
                BannerHeader("Library", subtitle: "Books, cast & insights")

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(LibraryViewModel.LibraryMode.allCases) { mode in
                            Button {
                                libraryMode = mode
                                HapticService.light()
                                SoundService.tap()
                            } label: {
                                VStack(spacing: 6) {
                                    Text(mode.rawValue)
                                        .font(.system(.subheadline, design: .serif))
                                        .foregroundStyle(
                                            libraryMode == mode
                                                ? Color("AppPrimary")
                                                : Color("AppTextSecondary")
                                        )
                                    Rectangle()
                                        .fill(libraryMode == mode ? Color("AppPrimary") : Color.clear)
                                        .frame(height: 2)
                                }
                                .padding(.horizontal, 14)
                                .padding(.top, 12)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 8)
                }
                .background(Color("AppSurface").opacity(0.55))

                Group {
                    switch libraryMode {
                    case .history:
                        historyContent
                    case .books:
                        booksContent
                    case .characters:
                        charactersContent
                    case .compare:
                        compareContent
                    case .insight:
                        insightContent
                            .padding(.top, 12)
                    }
                }
            }
        }
        .sheet(item: $selectedEvent) { event in
            EventDetailView(event: event, store: store)
        }
        .sheet(item: $selectedBook) { book in
            BookDetailView(store: store, book: book)
        }
        .sheet(item: $selectedCharacter) { character in
            CharacterDetailSheet(store: store, character: character) { event in
                selectedCharacter = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    selectedEvent = event
                }
            }
        }
    }

    @ViewBuilder
    private var historyContent: some View {
        if store.events.isEmpty {
            EmptyStateView(
                message: "Start tracking your book journey!",
                systemImage: "book.circle"
            )
        } else {
            VStack(spacing: 0) {
                EventFilterBar(
                    filter: $filter,
                    bookNames: store.allBookNames,
                    themes: store.allThemes,
                    tags: store.allTags
                )
                if historyEvents.isEmpty {
                    EmptyStateView(
                        message: "No events match your filters",
                        systemImage: "line.3.horizontal.decrease.circle"
                    )
                } else {
                    List {
                        ForEach(historyEvents) { event in
                            Button {
                                selectedEvent = event
                                HapticService.light()
                            } label: {
                                HStack(spacing: 12) {
                                    Image("stackBooks")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 44, height: 44)
                                        .clipped()
                                        .cornerRadius(2)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 2)
                                                .stroke(Color("AppPrimary").opacity(0.4), lineWidth: 1)
                                        )

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(event.title)
                                            .font(.system(.headline, design: .serif))
                                            .foregroundStyle(Color("AppTextPrimary"))
                                        Text(event.bookName)
                                            .font(.caption)
                                            .foregroundStyle(Color("AppTextSecondary"))
                                        HStack(spacing: 8) {
                                            Text(event.date, style: .date)
                                                .font(.caption2)
                                                .foregroundStyle(Color("AppPrimary"))
                                            if !event.quotes.isEmpty {
                                                Label("\(event.quotes.count)", systemImage: "quote.opening")
                                                    .font(.caption2)
                                                    .foregroundStyle(Color("AppAccent"))
                                            }
                                        }
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundStyle(Color("AppTextSecondary"))
                                }
                                .padding(.vertical, 4)
                            }
                            .listRowBackground(Color("AppSurface"))
                        }
                        .onMove { source, destination in
                            store.reorderEvents(from: source, to: destination)
                        }
                        .onDelete { offsets in
                            let ordered = historyEvents
                            for index in offsets {
                                store.deleteEvent(id: ordered[index].id)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .environment(\.editMode, .constant(.active))
                }
            }
        }
    }

    @ViewBuilder
    private var booksContent: some View {
        if store.books.isEmpty {
            EmptyStateView(
                message: "Books appear when you add events",
                systemImage: "books.vertical"
            )
        } else {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(store.books.sorted { $0.name < $1.name }) { book in
                        Button {
                            selectedBook = book
                            HapticService.light()
                            SoundService.tap()
                        } label: {
                            ManuscriptCard {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        Text(book.name)
                                            .font(.system(.headline, design: .serif))
                                            .foregroundStyle(Color("AppTextPrimary"))
                                        Spacer()
                                        Text(book.genre)
                                            .font(.caption)
                                            .foregroundStyle(Color("AppPrimary"))
                                    }
                                    let count = store.events(forBook: book.name).count
                                    Text(count == 1 ? "1 event" : "\(count) events")
                                        .font(.caption)
                                        .foregroundStyle(Color("AppTextSecondary"))
                                    GeometryReader { geo in
                                        let width = geo.size.width * store.progress(forBook: book.name)
                                        ZStack(alignment: .leading) {
                                            Capsule()
                                                .fill(Color("AppBackground").opacity(0.55))
                                                .frame(height: 8)
                                            Capsule()
                                                .fill(
                                                    LinearGradient(
                                                        colors: [Color("AppPrimary"), Color("AppAccent")],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                                .frame(width: max(width, count == 0 ? 0 : 8), height: 8)
                                        }
                                    }
                                    .frame(height: 8)
                                    if !book.notes.isEmpty {
                                        Text(book.notes)
                                            .font(.caption)
                                            .foregroundStyle(Color("AppTextSecondary"))
                                            .lineLimit(2)
                                    }
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
        }
    }

    @ViewBuilder
    private var charactersContent: some View {
        let characters = store.characters
        if characters.isEmpty {
            EmptyStateView(
                message: "Tag people on Character-themed events to build the cast map",
                systemImage: "person.3"
            )
        } else {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(characters) { character in
                        Button {
                            selectedCharacter = character
                            HapticService.light()
                        } label: {
                            ManuscriptCard {
                                HStack {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(character.name)
                                            .font(.system(.headline, design: .serif))
                                            .foregroundStyle(Color("AppTextPrimary"))
                                        Text(character.books.joined(separator: " · "))
                                            .font(.caption)
                                            .foregroundStyle(Color("AppTextSecondary"))
                                            .lineLimit(1)
                                    }
                                    Spacer()
                                    Text("\(character.eventCount)")
                                        .font(.system(.title2, design: .serif))
                                        .foregroundStyle(Color("AppPrimary"))
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
        }
    }

    @ViewBuilder
    private var compareContent: some View {
        let comparisons = store.bookComparisons
        if comparisons.count < 1 {
            EmptyStateView(
                message: "Add events across books to compare density and themes",
                systemImage: "chart.bar.xaxis"
            )
        } else {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(comparisons) { item in
                        ManuscriptCard {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text(item.name)
                                        .font(.system(.headline, design: .serif))
                                        .foregroundStyle(Color("AppTextPrimary"))
                                    Spacer()
                                    Text(item.genre)
                                        .font(.caption)
                                        .foregroundStyle(Color("AppAccent"))
                                }
                                GoldDivider()
                                compareRow("Events", "\(item.eventCount)")
                                compareRow("Quotes", "\(item.quoteCount)")
                                compareRow("Dominant theme", item.dominantTheme)
                                compareRow("Span", "\(item.spanDays)d")
                                compareRow(
                                    "Density",
                                    String(format: "%.1f / week", item.densityPerWeek)
                                )
                                GeometryReader { geo in
                                    let maxDensity = max(comparisons.map(\.densityPerWeek).max() ?? 1, 0.1)
                                    let width = geo.size.width * CGFloat(item.densityPerWeek / maxDensity)
                                    ZStack(alignment: .leading) {
                                        Capsule()
                                            .fill(Color("AppBackground").opacity(0.55))
                                            .frame(height: 8)
                                        Capsule()
                                            .fill(Color("AppPrimary"))
                                            .frame(width: max(width, 8), height: 8)
                                    }
                                }
                                .frame(height: 8)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
        }
    }

    private func compareRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundStyle(Color("AppTextSecondary"))
            Spacer()
            Text(value)
                .font(.caption)
                .foregroundStyle(Color("AppTextPrimary"))
        }
    }

    @ViewBuilder
    private var insightContent: some View {
        if store.events.isEmpty {
            EmptyStateView(
                message: "No events yet",
                systemImage: "chart.bar.doc.horizontal"
            )
        } else {
            VStack(spacing: 16) {
                Picker("Segment", selection: $segment) {
                    ForEach(InsightSegment.allCases) { item in
                        Text(item.rawValue).tag(item)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .onChange(of: segment) { _ in
                    HapticService.light()
                    SoundService.tap()
                }

                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(insightGroups) { group in
                            ManuscriptCard {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        Text(group.name)
                                            .font(.system(.headline, design: .serif))
                                            .foregroundStyle(Color("AppTextPrimary"))
                                        Spacer()
                                        Text("\(group.count)")
                                            .font(.system(.title2, design: .serif))
                                            .foregroundStyle(Color("AppPrimary"))
                                    }

                                    GeometryReader { geo in
                                        let maxCount = max(insightGroups.map(\.count).max() ?? 1, 1)
                                        let width = geo.size.width * CGFloat(group.count) / CGFloat(maxCount)
                                        ZStack(alignment: .leading) {
                                            Capsule()
                                                .fill(Color("AppBackground").opacity(0.55))
                                                .frame(height: 10)
                                            Capsule()
                                                .fill(
                                                    LinearGradient(
                                                        colors: [Color("AppPrimary"), Color("AppAccent")],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                                .frame(width: max(width, 10), height: 10)
                                        }
                                    }
                                    .frame(height: 10)

                                    Text(group.count == 1 ? "1 event recorded" : "\(group.count) events recorded")
                                        .font(.caption)
                                        .foregroundStyle(Color("AppTextSecondary"))
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.bottom, 24)
                }
            }
        }
    }

    private func grouped(by key: (BookEvent) -> String) -> [InsightGroup] {
        let dict = Dictionary(grouping: store.events, by: key)
        return dict
            .map { InsightGroup(name: $0.key, count: $0.value.count) }
            .sorted { $0.count > $1.count }
    }
}

private struct CharacterDetailSheet: View {
    @ObservedObject var store: DataStore
    let character: CharacterEntry
    let onSelectEvent: (BookEvent) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Color("AppBackground").ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ManuscriptCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(character.name)
                                    .font(.system(.title2, design: .serif))
                                    .foregroundStyle(Color("AppTextPrimary"))
                                Text(character.books.joined(separator: " · "))
                                    .font(.subheadline)
                                    .foregroundStyle(Color("AppTextSecondary"))
                                Text("\(character.eventCount) linked events")
                                    .font(.caption)
                                    .foregroundStyle(Color("AppPrimary"))
                            }
                        }

                        ForEach(character.eventIDs.compactMap { store.event(id: $0) }) { event in
                            Button {
                                onSelectEvent(event)
                            } label: {
                                ManuscriptCard {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(event.title)
                                            .font(.system(.headline, design: .serif))
                                            .foregroundStyle(Color("AppTextPrimary"))
                                        Text(event.bookName)
                                            .font(.caption)
                                            .foregroundStyle(Color("AppTextSecondary"))
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Character")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
        }
    }
}
