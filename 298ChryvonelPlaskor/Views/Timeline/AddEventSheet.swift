import SwiftUI

struct AddEventSheet: View {
    @ObservedObject var store: DataStore
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var description = ""
    @State private var date = Date()
    @State private var tagsText = ""
    @State private var bookName = ""
    @State private var theme = "General"
    @State private var selectedTemplate: EventTemplate?
    @State private var genreHint = "General"
    @State private var links: [EventLink] = []
    @State private var quotes: [Quote] = []

    private let themes = ["General", "Plot", "Character", "Setting", "Conflict", "Resolution"]

    var body: some View {
        NavigationView {
            ZStack {
                Color("AppBackground").ignoresSafeArea()
                    .dismissKeyboardOnTap()
                Form {
                    Section("Template") {
                        Picker("Genre template", selection: $selectedTemplate) {
                            Text("None").tag(Optional<EventTemplate>.none)
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
                            genreHint = template.bookGenre
                        }
                    }
                    .listRowBackground(Color("AppSurface"))

                    Section {
                        TextField("Event title", text: $title)
                        TextField("Book name", text: $bookName)
                        if !store.allBookNames.isEmpty {
                            Picker("Existing book", selection: $bookName) {
                                Text("Custom / new").tag("")
                                ForEach(store.allBookNames, id: \.self) { name in
                                    Text(name).tag(name)
                                }
                            }
                        }
                        Picker("Book genre", selection: $genreHint) {
                            ForEach(BookRecord.genres, id: \.self) { Text($0) }
                        }
                        TextField("Description", text: $description, axis: .vertical)
                            .lineLimit(3...6)
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
                        availableEvents: store.chronologicalEvents
                    )
                }
                .scrollContentBackground(.hidden)
                .scrollDismissesKeyboard(.interactively)
                .dismissKeyboardOnTap()
            }
            .navigationTitle("New Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .foregroundStyle(Color("AppPrimary"))
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
        let event = BookEvent(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            date: date,
            tags: tags,
            bookName: bookName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? "Untitled Book"
                : bookName.trimmingCharacters(in: .whitespacesAndNewlines),
            theme: theme,
            links: links,
            quotes: quotes
        )
        store.addEvent(event, genreHint: genreHint)
        dismiss()
    }
}
