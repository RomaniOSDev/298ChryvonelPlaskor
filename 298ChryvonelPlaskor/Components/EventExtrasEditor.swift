import SwiftUI

struct EventExtrasEditor: View {
    @Binding var links: [EventLink]
    @Binding var quotes: [Quote]
    let availableEvents: [BookEvent]

    @State private var linkType: EventLinkType = .causes
    @State private var linkTargetID: UUID?
    @State private var quoteText = ""
    @State private var quoteAttribution = ""

    var body: some View {
        Group {
            Section("Story Links") {
                if availableEvents.isEmpty {
                    Text("Add more events to create links.")
                        .foregroundStyle(Color("AppTextSecondary"))
                } else {
                    Picker("Link type", selection: $linkType) {
                        ForEach(EventLinkType.allCases) { type in
                            Text(type.title).tag(type)
                        }
                    }
                    Picker("Linked event", selection: $linkTargetID) {
                        Text("Select event").tag(Optional<UUID>.none)
                        ForEach(availableEvents) { event in
                            Text(event.title).tag(Optional(event.id))
                        }
                    }
                    Button("Add Link") {
                        guard let target = linkTargetID else { return }
                        links.append(EventLink(targetEventID: target, type: linkType))
                        linkTargetID = nil
                        HapticService.light()
                    }
                    .disabled(linkTargetID == nil)

                    ForEach(links) { link in
                        HStack {
                            Image(systemName: link.type.symbol)
                                .foregroundStyle(Color("AppPrimary"))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(link.type.title)
                                    .font(.subheadline)
                                Text(title(for: link.targetEventID))
                                    .font(.caption)
                                    .foregroundStyle(Color("AppTextSecondary"))
                            }
                            Spacer()
                            Button(role: .destructive) {
                                links.removeAll { $0.id == link.id }
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
                    }
                }
            }
            .listRowBackground(Color("AppSurface"))

            Section("Quotes") {
                TextField("Quote text", text: $quoteText, axis: .vertical)
                    .lineLimit(2...4)
                TextField("Attribution (optional)", text: $quoteAttribution)
                Button("Add Quote") {
                    let text = quoteText.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !text.isEmpty else { return }
                    quotes.append(
                        Quote(
                            text: text,
                            attribution: quoteAttribution.trimmingCharacters(in: .whitespacesAndNewlines)
                        )
                    )
                    quoteText = ""
                    quoteAttribution = ""
                    HapticService.light()
                }
                .disabled(quoteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                ForEach(quotes) { quote in
                    VStack(alignment: .leading, spacing: 4) {
                        Text("“\(quote.text)”")
                            .font(.system(.body, design: .serif))
                        if !quote.attribution.isEmpty {
                            Text("— \(quote.attribution)")
                                .font(.caption)
                                .foregroundStyle(Color("AppTextSecondary"))
                        }
                        Button("Remove", role: .destructive) {
                            quotes.removeAll { $0.id == quote.id }
                        }
                        .font(.caption)
                    }
                }
            }
            .listRowBackground(Color("AppSurface"))
        }
    }

    private func title(for id: UUID) -> String {
        availableEvents.first { $0.id == id }?.title ?? "Unknown event"
    }
}
