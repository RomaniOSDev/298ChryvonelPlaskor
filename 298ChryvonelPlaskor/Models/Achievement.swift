import Foundation

enum AchievementID: String, Codable, CaseIterable, Identifiable {
    case firstEvent
    case timelineBuilder
    case chronicleMaster
    case dailyTracker
    case activeReader
    case seasonedTracker
    case eventExplorer
    case journeyRecorder

    var id: String { rawValue }

    var title: String {
        switch self {
        case .firstEvent: return "First Event"
        case .timelineBuilder: return "Timeline Builder"
        case .chronicleMaster: return "Chronicle Master"
        case .dailyTracker: return "Daily Tracker"
        case .activeReader: return "Active Reader"
        case .seasonedTracker: return "Seasoned Tracker"
        case .eventExplorer: return "Event Explorer"
        case .journeyRecorder: return "Journey Recorder"
        }
    }

    var detail: String {
        switch self {
        case .firstEvent: return "Create your first book event"
        case .timelineBuilder: return "Record 10 events on your timeline"
        case .chronicleMaster: return "Record 50 events on your timeline"
        case .dailyTracker: return "Maintain a 7-day streak"
        case .activeReader: return "Complete 15 reading sessions"
        case .seasonedTracker: return "Maintain a 30-day streak"
        case .eventExplorer: return "Create 25 book events"
        case .journeyRecorder: return "Complete 100 reading sessions"
        }
    }

    var iconName: String {
        switch self {
        case .firstEvent: return "sparkles"
        case .timelineBuilder: return "timeline.selection"
        case .chronicleMaster: return "book.closed.fill"
        case .dailyTracker: return "flame.fill"
        case .activeReader: return "eyeglasses"
        case .seasonedTracker: return "crown.fill"
        case .eventExplorer: return "map.fill"
        case .journeyRecorder: return "scroll.fill"
        }
    }

    func isUnlocked(stats: UserStats) -> Bool {
        switch self {
        case .firstEvent: return stats.itemsCreated >= 1
        case .timelineBuilder: return stats.itemsCreated >= 10
        case .chronicleMaster: return stats.itemsCreated >= 50
        case .dailyTracker: return stats.streakDays >= 7
        case .activeReader: return stats.sessionsCompleted >= 15
        case .seasonedTracker: return stats.streakDays >= 30
        case .eventExplorer: return stats.itemsCreated >= 25
        case .journeyRecorder: return stats.sessionsCompleted >= 100
        }
    }

    func progress(stats: UserStats) -> Double {
        switch self {
        case .firstEvent: return min(1, Double(stats.itemsCreated) / 1)
        case .timelineBuilder: return min(1, Double(stats.itemsCreated) / 10)
        case .chronicleMaster: return min(1, Double(stats.itemsCreated) / 50)
        case .dailyTracker: return min(1, Double(stats.streakDays) / 7)
        case .activeReader: return min(1, Double(stats.sessionsCompleted) / 15)
        case .seasonedTracker: return min(1, Double(stats.streakDays) / 30)
        case .eventExplorer: return min(1, Double(stats.itemsCreated) / 25)
        case .journeyRecorder: return min(1, Double(stats.sessionsCompleted) / 100)
        }
    }
}

struct UnlockedAchievement: Identifiable, Codable, Equatable {
    var id: String { achievementID.rawValue }
    var achievementID: AchievementID
    var unlockedAt: Date
}
