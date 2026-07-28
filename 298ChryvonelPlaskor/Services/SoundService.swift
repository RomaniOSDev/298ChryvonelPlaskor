import AudioToolbox
import Foundation

enum SoundService {
    /// System click/success sounds are used — feature is available.
    static let isAvailable = true

    private static let defaultsKey = "sound_enabled"

    static var isEnabled: Bool {
        get {
            if UserDefaults.standard.object(forKey: defaultsKey) == nil { return true }
            return UserDefaults.standard.bool(forKey: defaultsKey)
        }
        set { UserDefaults.standard.set(newValue, forKey: defaultsKey) }
    }

    static func tap() {
        guard isAvailable, isEnabled else { return }
        AudioServicesPlaySystemSound(1104)
    }

    static func success() {
        guard isAvailable, isEnabled else { return }
        AudioServicesPlaySystemSound(1025)
    }

    static func achievement() {
        guard isAvailable, isEnabled else { return }
        AudioServicesPlaySystemSound(1335)
    }
}
