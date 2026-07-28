import UIKit

enum HapticService {
    static let isAvailable = true

    private static let defaultsKey = "haptic_enabled"

    static var isEnabled: Bool {
        get {
            if UserDefaults.standard.object(forKey: defaultsKey) == nil { return true }
            return UserDefaults.standard.bool(forKey: defaultsKey)
        }
        set { UserDefaults.standard.set(newValue, forKey: defaultsKey) }
    }

    static func light() {
        guard isAvailable, isEnabled else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func medium() {
        guard isAvailable, isEnabled else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func success() {
        guard isAvailable, isEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func warning() {
        guard isAvailable, isEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
}
