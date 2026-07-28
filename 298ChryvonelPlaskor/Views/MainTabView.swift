import SwiftUI

struct MainTabView: View {
    @ObservedObject var store: DataStore
    @State private var selection: AppTab = .timeline

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                Group {
                    switch selection {
                    case .timeline:
                        TimelineView(store: store)
                    case .library:
                        LibraryView(store: store)
                    case .stats:
                        StatsView(store: store)
                    case .achievements:
                        AchievementsView(store: store)
                    case .settings:
                        SettingsView(store: store)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                LiteraryTabBar(selection: $selection)
            }

            if let achievement = store.bannerAchievement {
                AchievementBannerOverlay(achievement: achievement) {
                    store.bannerAchievement = nil
                }
                .zIndex(10)
            }
        }
        .preferredColorScheme(store.appearance.colorScheme)
        .environment(\.sizeCategory, store.fontSize.sizeCategory)
    }
}
