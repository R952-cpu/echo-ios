import Foundation

/// Thread-safe mapper from peer IDs to fingerprints with persistence.
final class PeerFingerprintMapper {
    static let shared = PeerFingerprintMapper()

    private let defaults: UserDefaults
    private let storageKey = "peerFingerprintMap:v1"
    private let queue = DispatchQueue(label: "io.echo.identity.PeerFingerprintMapper", attributes: .concurrent)
    private var map: [String: String]

    init(defaults: UserDefaults = UserDefaults(suiteName: "io.echo.identity") ?? .standard) {
        self.defaults = defaults
        self.map = defaults.dictionary(forKey: storageKey) as? [String: String] ?? [:]
    }

    // MARK: - Public API

    func fingerprint(forPeerID peerID: String) -> String? {
        var result: String?
        queue.sync { result = map[peerID] }
        return result
    }

    func peerIDs(forFingerprint fingerprint: String) -> [String] {
        var result: [String] = []
        queue.sync {
            result = map.compactMap { $0.value == fingerprint ? $0.key : nil }
        }
        return result
    }

    func setMapping(peerID: String, fingerprint: String) {
        queue.sync(flags: .barrier) {
            map[peerID] = fingerprint
            persist()
        }
    }

    func removePeerID(_ peerID: String) {
        queue.sync(flags: .barrier) {
            map.removeValue(forKey: peerID)
            persist()
        }
    }

    func removeAll(forFingerprint fingerprint: String) {
        queue.sync(flags: .barrier) {
            map = map.filter { $0.value != fingerprint }
            persist()
        }
    }

    // MARK: - Persistence

    private func persist() {
        defaults.set(map, forKey: storageKey)
    }
}

