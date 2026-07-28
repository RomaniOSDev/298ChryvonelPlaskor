import Foundation
import Combine

final class AchievementsViewModel: ObservableObject {
    private let store: DataStore

    init(store: DataStore = .shared) {
        self.store = store
    }

    var stats: UserStats { store.stats }

    var items: [(achievement: AchievementID, unlocked: Bool, progress: Double)] {
        AchievementID.allCases.map { id in
            (id, id.isUnlocked(stats: stats), id.progress(stats: stats))
        }
    }

    var unlockedCount: Int {
        items.filter(\.unlocked).count
    }
}
