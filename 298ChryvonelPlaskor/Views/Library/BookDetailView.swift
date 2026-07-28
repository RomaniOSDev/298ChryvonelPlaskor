import SwiftUI

struct BookDetailView: View {
    @ObservedObject var store: DataStore
    let book: BookRecord
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var genre: String
    @State private var notes: String
    @State private var selectedEvent: BookEvent?

    init(store: DataStore, book: BookRecord) {
        self.store = store
        self.book = book
        _name = State(initialValue: book.name)
        _genre = State(initialValue: book.genre)
        _notes = State(initialValue: book.notes)
    }

    private var bookEvents: [BookEvent] {
        store.events(forBook: book.name)
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color("AppBackground").ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        ManuscriptCard {
                            VStack(alignment: .leading, spacing: 10) {
                                TextField("Book name", text: $name)
                                    .font(.system(.title3, design: .serif))
                                    .foregroundStyle(Color("AppTextPrimary"))
                                Picker("Genre", selection: $genre) {
                                    ForEach(BookRecord.genres, id: \.self) { Text($0) }
                                }
                                TextField("Notes", text: $notes, axis: .vertical)
                                    .lineLimit(2...5)
                                    .foregroundStyle(Color("AppTextSecondary"))

                                GoldDivider()

                                HStack {
                                    Text("Progress")
                                        .font(.caption)
                                        .foregroundStyle(Color("AppTextSecondary"))
                                    Spacer()
                                    Text("\(bookEvents.count) events")
                                        .font(.caption)
                                        .foregroundStyle(Color("AppPrimary"))
                                }
                                GeometryReader { geo in
                                    let width = geo.size.width * store.progress(forBook: book.name)
                                    ZStack(alignment: .leading) {
                                        Capsule()
                                            .fill(Color("AppBackground").opacity(0.55))
                                            .frame(height: 8)
                                        Capsule()
                                            .fill(Color("AppPrimary"))
                                            .frame(width: max(width, bookEvents.isEmpty ? 0 : 8), height: 8)
                                    }
                                }
                                .frame(height: 8)
                            }
                        }

                        Text("Timeline")
                            .font(.system(.title3, design: .serif))
                            .foregroundStyle(Color("AppTextPrimary"))
                            .padding(.top, 4)

                        if bookEvents.isEmpty {
                            Text("No events for this book yet.")
                                .foregroundStyle(Color("AppTextSecondary"))
                        } else {
                            ForEach(Array(bookEvents.enumerated()), id: \.element.id) { index, event in
                                TimelineSpineRow(
                                    event: event,
                                    isFirst: index == 0,
                                    isLast: index == bookEvents.count - 1
                                ) {
                                    selectedEvent = event
                                    HapticService.light()
                                }
                            }
                        }
                    }
                    .padding(16)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
        .sheet(item: $selectedEvent) { event in
            EventDetailView(event: event, store: store)
        }
    }

    private func save() {
        var updated = book
        updated.name = name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? book.name
            : name.trimmingCharacters(in: .whitespacesAndNewlines)
        updated.genre = genre
        updated.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        store.updateBook(updated)
        dismiss()
    }
}
