import Foundation
import Combine
import StoreKit
import UIKit

final class SettingsViewModel: ObservableObject {
    @Published var showResetConfirm = false

    private let store: DataStore

    init(store: DataStore = .shared) {
        self.store = store
    }

    var stats: UserStats { store.stats }
    var eventCount: Int { store.events.count }

    func requestReview() {
        HapticService.light()
        SoundService.tap()
        if let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) {
            SKStoreReviewController.requestReview(in: scene)
        }
    }

    func resetAllData() {
        store.resetAllData()
        showResetConfirm = false
    }
}
