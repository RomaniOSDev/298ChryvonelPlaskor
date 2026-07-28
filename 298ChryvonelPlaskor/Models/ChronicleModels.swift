import Foundation
import SwiftUI

enum EventLinkType: String, Codable, CaseIterable, Identifiable {
    case causes
    case causedBy
    case flashback
    case foreshadows

    var id: String { rawValue }

    var title: String {
        switch self {
        case .causes: return "Causes"
        case .causedBy: return "Caused by"
        case .flashback: return "Flashback to"
        case .foreshadows: return "Foreshadows"
        }
    }

    var symbol: String {
        switch self {
        case .causes: return "arrow.right.circle"
        case .causedBy: return "arrow.left.circle"
        case .flashback: return "clock.arrow.circlepath"
        case .foreshadows: return "eye"
        }
    }
}

struct EventLink: Identifiable, Codable, Equatable {
    var id: UUID
    var targetEventID: UUID
    var type: EventLinkType

    init(id: UUID = UUID(), targetEventID: UUID, type: EventLinkType) {
        self.id = id
        self.targetEventID = targetEventID
        self.type = type
    }
}

struct Quote: Identifiable, Codable, Equatable {
    var id: UUID
    var text: String
    var attribution: String
    var createdAt: Date

    init(id: UUID = UUID(), text: String, attribution: String = "", createdAt: Date = Date()) {
        self.id = id
        self.text = text
        self.attribution = attribution
        self.createdAt = createdAt
    }
}

struct BookRecord: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var genre: String
    var notes: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        genre: String = "General",
        notes: String = "",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.genre = genre
        self.notes = notes
        self.createdAt = createdAt
    }

    static let genres = ["General", "Detective", "Fantasy", "Non-fiction", "Romance", "Sci-Fi", "Other"]
}

enum EventTemplate: String, CaseIterable, Identifiable {
    case detectiveClue
    case detectiveReveal
    case fantasyQuest
    case fantasyMagic
    case nonfictionInsight
    case nonfictionFact

    var id: String { rawValue }

    var label: String {
        switch self {
        case .detectiveClue: return "Detective · Clue"
        case .detectiveReveal: return "Detective · Reveal"
        case .fantasyQuest: return "Fantasy · Quest"
        case .fantasyMagic: return "Fantasy · Magic"
        case .nonfictionInsight: return "Non-fiction · Insight"
        case .nonfictionFact: return "Non-fiction · Key Fact"
        }
    }

    var title: String {
        switch self {
        case .detectiveClue: return "A new clue surfaces"
        case .detectiveReveal: return "The truth is revealed"
        case .fantasyQuest: return "The quest advances"
        case .fantasyMagic: return "Magic changes the course"
        case .nonfictionInsight: return "Key insight"
        case .nonfictionFact: return "Notable fact"
        }
    }

    var theme: String {
        switch self {
        case .detectiveClue, .detectiveReveal, .fantasyQuest: return "Plot"
        case .fantasyMagic: return "Conflict"
        case .nonfictionInsight, .nonfictionFact: return "General"
        }
    }

    var tags: [String] {
        switch self {
        case .detectiveClue: return ["clue", "mystery"]
        case .detectiveReveal: return ["reveal", "mystery"]
        case .fantasyQuest: return ["quest", "journey"]
        case .fantasyMagic: return ["magic", "power"]
        case .nonfictionInsight: return ["insight"]
        case .nonfictionFact: return ["fact"]
        }
    }

    var bookGenre: String {
        switch self {
        case .detectiveClue, .detectiveReveal: return "Detective"
        case .fantasyQuest, .fantasyMagic: return "Fantasy"
        case .nonfictionInsight, .nonfictionFact: return "Non-fiction"
        }
    }

    var detail: String {
        switch self {
        case .detectiveClue: return "Note the clue and how it shifts suspicion."
        case .detectiveReveal: return "Capture the reveal and its consequences."
        case .fantasyQuest: return "Record the next step on the hero's path."
        case .fantasyMagic: return "Describe the magical turn and who it affects."
        case .nonfictionInsight: return "Summarize the insight worth remembering."
        case .nonfictionFact: return "Capture the fact and why it matters."
        }
    }
}

enum AppAppearance: String, CaseIterable, Identifiable {
    case system
    case dark
    case light

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: return "System"
        case .dark: return "Dark"
        case .light: return "Light"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .dark: return .dark
        case .light: return .light
        }
    }
}

enum AppFontSize: String, CaseIterable, Identifiable {
    case small
    case medium
    case large

    var id: String { rawValue }

    var title: String {
        switch self {
        case .small: return "Small"
        case .medium: return "Medium"
        case .large: return "Large"
        }
    }

    var sizeCategory: ContentSizeCategory {
        switch self {
        case .small: return .medium
        case .medium: return .large
        case .large: return .extraExtraLarge
        }
    }
}

struct CharacterEntry: Identifiable, Equatable {
    var id: String { name.lowercased() }
    var name: String
    var eventCount: Int
    var books: [String]
    var eventIDs: [UUID]
}

struct BookComparison: Identifiable, Equatable {
    var id: String { name }
    var name: String
    var genre: String
    var eventCount: Int
    var quoteCount: Int
    var dominantTheme: String
    var densityPerWeek: Double
    var spanDays: Int
}
