import SwiftUI

struct EventDetailView: View {
    let event: BookEvent
    @ObservedObject var store: DataStore
    @Environment(\.dismiss) private var dismiss

    @State private var title: String
    @State private var description: String
    @State private var date: Date
    @State private var tagsText: String
    @State private var bookName: String
    @State private var theme: String
    @State private var links: [EventLink]
    @State private var quotes: [Quote]
    @State private var selectedTemplate: EventTemplate?

    private let themes = ["General", "Plot", "Character", "Setting", "Conflict", "Resolution"]

    init(event: BookEvent, store: DataStore) {
        self.event = event
        self.store = store
        _title = State(initialValue: event.title)
        _description = State(initialValue: event.description)
        _date = State(initialValue: event.date)
        _tagsText = State(initialValue: event.tags.joined(separator: ", "))
        _bookName = State(initialValue: event.bookName)
        _theme = State(initialValue: event.theme)
        _links = State(initialValue: event.links)
        _quotes = State(initialValue: event.quotes)
    }

    private var availableLinkTargets: [BookEvent] {
        store.chronologicalEvents.filter { $0.id != event.id }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color("AppBackground").ignoresSafeArea()
                    .dismissKeyboardOnTap()
                Form {
                    Section("Template") {
                        Picker("Apply template", selection: $selectedTemplate) {
                            Text("Keep current").tag(Optional<EventTemplate>.none)
                            ForEach(EventTemplate.allCases) { template in
                                Text(template.label).tag(Optional(template))
                            }
                        }
                        .onChange(of: selectedTemplate) { template in
                            guard let template else { return }
                            title = template.title
                            description = template.detail
                            theme = template.theme
                            tagsText = template.tags.joined(separator: ", ")
                        }
                    }
                    .listRowBackground(Color("AppSurface"))

                    Section {
                        TextField("Event title", text: $title)
                        TextField("Book name", text: $bookName)
                        TextField("Description", text: $description, axis: .vertical)
                            .lineLimit(3...8)
                        DatePicker("Date", selection: $date, displayedComponents: .date)
                        TextField("Tags (comma separated)", text: $tagsText)
                        Picker("Theme", selection: $theme) {
                            ForEach(themes, id: \.self) { Text($0) }
                        }
                    }
                    .listRowBackground(Color("AppSurface"))

                    EventExtrasEditor(
                        links: $links,
                        quotes: $quotes,
                        availableEvents: availableLinkTargets
                    )

                    Section {
                        Button(role: .destructive) {
                            store.deleteEvent(id: event.id)
                            dismiss()
                        } label: {
                            Text("Delete Event")
                        }
                    }
                    .listRowBackground(Color("AppSurface"))
                }
                .scrollContentBackground(.hidden)
                .scrollDismissesKeyboard(.interactively)
                .dismissKeyboardOnTap()
            }
            .navigationTitle("Event Details")
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
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { KeyboardDismiss.hide() }
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
    }

    private func save() {
        let tags = tagsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        var updated = event
        updated.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        updated.description = description.trimmingCharacters(in: .whitespacesAndNewlines)
        updated.date = date
        updated.tags = tags
        updated.bookName = bookName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "Untitled Book"
            : bookName.trimmingCharacters(in: .whitespacesAndNewlines)
        updated.theme = theme
        updated.links = links
        updated.quotes = quotes
        store.updateEvent(updated)
        dismiss()
    }
}
