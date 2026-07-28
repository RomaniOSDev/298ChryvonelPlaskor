import SwiftUI

struct TimelineView: View {
    @ObservedObject var store: DataStore
    @State private var showingAddSheet = false
    @State private var selectedEvent: BookEvent?
    @State private var filter = EventFilter()

    private var events: [BookEvent] { store.filteredChronological(filter) }

    var body: some View {
        AppBackground {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
                    BannerHeader("Event Timeline", subtitle: "Chronicle your reading journey")

                    if !store.events.isEmpty {
                        EventFilterBar(
                            filter: $filter,
                            bookNames: store.allBookNames,
                            themes: store.allThemes,
                            tags: store.allTags
                        )
                    }

                    if store.events.isEmpty {
                        EmptyStateView(
                            message: "Get started by adding first book event",
                            systemImage: "plus.circle"
                        )
                    } else if events.isEmpty {
                        EmptyStateView(
                            message: "No events match your filters",
                            systemImage: "line.3.horizontal.decrease.circle"
                        )
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 0) {
                                ForEach(Array(events.enumerated()), id: \.element.id) { index, event in
                                    TimelineSpineRow(
                                        event: event,
                                        isFirst: index == 0,
                                        isLast: index == events.count - 1,
                                        linkedTitles: linkedTitles(for: event)
                                    ) {
                                        selectedEvent = event
                                        HapticService.light()
                                    }
                                    .padding(.leading, 16)
                                    .padding(.trailing, 12)
                                }
                            }
                            .padding(.top, 12)
                            .padding(.bottom, 88)
                        }
                    }
                }

                FABButton {
                    showingAddSheet = true
                    HapticService.medium()
                    SoundService.tap()
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddEventSheet(store: store)
        }
        .sheet(item: $selectedEvent) { event in
            EventDetailView(event: event, store: store)
        }
    }

    private func linkedTitles(for event: BookEvent) -> [String] {
        event.links.compactMap { link in
            store.event(id: link.targetEventID).map { "\(link.type.title): \($0.title)" }
        }
    }
}
