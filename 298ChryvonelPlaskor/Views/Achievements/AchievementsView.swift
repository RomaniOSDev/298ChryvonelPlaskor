import SwiftUI

struct AchievementsView: View {
    @ObservedObject var store: DataStore

    private var items: [(achievement: AchievementID, unlocked: Bool, progress: Double)] {
        AchievementID.allCases.map { id in
            (id, id.isUnlocked(stats: store.stats), id.progress(stats: store.stats))
        }
    }

    private var unlockedCount: Int {
        items.filter(\.unlocked).count
    }

    var body: some View {
        AppBackground {
            VStack(spacing: 0) {
                BannerHeader(
                    "Achievements",
                    subtitle: "\(unlockedCount) of \(AchievementID.allCases.count) unlocked"
                )

                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(items, id: \.achievement.id) { item in
                            ManuscriptCard {
                                HStack(spacing: 14) {
                                    Image(systemName: item.achievement.iconName)
                                        .font(.title2)
                                        .foregroundStyle(
                                            item.unlocked
                                                ? Color("AppBackground")
                                                : Color("AppTextSecondary")
                                        )
                                        .frame(width: 48, height: 48)
                                        .background(
                                            Circle()
                                                .fill(
                                                    item.unlocked
                                                        ? Color("AppPrimary")
                                                        : Color("AppBackground").opacity(0.5)
                                                )
                                        )

                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(item.achievement.title)
                                            .font(.system(.headline, design: .serif))
                                            .foregroundStyle(Color("AppTextPrimary"))
                                        Text(item.achievement.detail)
                                            .font(.caption)
                                            .foregroundStyle(Color("AppTextSecondary"))

                                        GeometryReader { geo in
                                            ZStack(alignment: .leading) {
                                                Capsule()
                                                    .fill(Color("AppBackground").opacity(0.55))
                                                    .frame(height: 6)
                                                Capsule()
                                                    .fill(Color("AppPrimary"))
                                                    .frame(width: geo.size.width * item.progress, height: 6)
                                            }
                                        }
                                        .frame(height: 6)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .opacity(item.unlocked ? 1 : 0.72)
                        }
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 28)
                }
            }
        }
    }
}
