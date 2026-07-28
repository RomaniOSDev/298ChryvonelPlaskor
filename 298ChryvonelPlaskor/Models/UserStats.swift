import Foundation

struct UserStats: Codable, Equatable {
    var itemsCreated: Int
    var streakDays: Int
    var sessionsCompleted: Int
    var lastActiveDate: Date?
    var unlockedAchievements: [UnlockedAchievement]

    static let empty = UserStats(
        itemsCreated: 0,
        streakDays: 0,
        sessionsCompleted: 0,
        lastActiveDate: nil,
        unlockedAchievements: []
    )
}
