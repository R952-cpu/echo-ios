import Foundation

/// Represents the consent status for private messages between two peers.
enum PMConsentStatus: String {
    case unknown
    case requested
    case accepted
    case refused
}

/// Stores and retrieves private message consent statuses between peers.
/// Uses fingerprints as identifiers and persists data in UserDefaults.
final class PMConsentStore {
    static let shared = PMConsentStore()

    private let userDefaults: UserDefaults
    private let storagePrefix = "chat.bitchat.pmconsent"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    /// Retrieves the consent status between two fingerprints.
    func status(between myFingerprint: String, and otherFingerprint: String) -> PMConsentStatus {
        let key = storageKey(for: myFingerprint, and: otherFingerprint)
        if let raw = userDefaults.string(forKey: key), let status = PMConsentStatus(rawValue: raw) {
            return status
        }
        return .unknown
    }

    /// Sets the consent status between two fingerprints.
    func setStatus(_ status: PMConsentStatus, between firstFingerprint: String, and secondFingerprint: String) {
        let key = storageKey(for: firstFingerprint, and: secondFingerprint)
        if status == .unknown {
            userDefaults.removeObject(forKey: key)
        } else {
            userDefaults.set(status.rawValue, forKey: key)
        }
        userDefaults.synchronize()
    }

    /// Creates a deterministic key for two fingerprints.
    private func storageKey(for fingerprintA: String, and fingerprintB: String) -> String {
        let sorted = [fingerprintA, fingerprintB].sorted()
        return "\(storagePrefix).\(sorted[0])|\(sorted[1])"
    }
}

