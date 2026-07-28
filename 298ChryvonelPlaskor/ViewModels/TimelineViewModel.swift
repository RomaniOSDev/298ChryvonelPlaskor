import Foundation
import Combine

final class TimelineViewModel: ObservableObject {
    @Published var showingAddSheet = false
    @Published var selectedEvent: BookEvent?

    private let store: DataStore

    init(store: DataStore = .shared) {
        self.store = store
    }

    var events: [BookEvent] {
        store.chronologicalEvents
    }

    var isEmpty: Bool { store.events.isEmpty }

    func openAdd() {
        showingAddSheet = true
        HapticService.medium()
        SoundService.tap()
    }
}
