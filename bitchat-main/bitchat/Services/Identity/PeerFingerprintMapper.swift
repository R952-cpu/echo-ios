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
        if let saved = defaults.dictionary(forKey: storageKey) as? [String: String] {
            self.map = Dictionary(uniqueKeysWithValues: saved.map { (canonical($0.key), canonical($0.value)) })
        } else {
            self.map = [:]
        }
    }

    // MARK: - Public API

    func fingerprint(forPeerID peerID: String) -> String? {
        let key = canonical(peerID)
        var result: String?
        queue.sync { result = map[key] }
        return result
    }

    func peerIDs(forFingerprint fingerprint: String) -> [String] {
        let value = canonical(fingerprint)
        var result: [String] = []
        queue.sync {
            result = map.compactMap { $0.value == value ? $0.key : nil }
        }
        return result
    }

    func setMapping(peerID: String, fingerprint: String) {
        let key = canonical(peerID)
        let value = canonical(fingerprint)
        queue.async(flags: .barrier) {
            self.map[key] = value
            self.persist()
        }
    }

    func removePeerID(_ peerID: String) {
        let key = canonical(peerID)
        queue.async(flags: .barrier) {
            self.map.removeValue(forKey: key)
            self.persist()
        }
    }

    func removeAll(forFingerprint fingerprint: String) {
        let value = canonical(fingerprint)
        queue.async(flags: .barrier) {
            self.map = self.map.filter { $0.value != value }
            self.persist()
        }
    }

    func removeAll() {
        queue.async(flags: .barrier) {
            self.map.removeAll()
            self.persist()
        }
    }

    // MARK: - Persistence

    private func persist() {
        defaults.set(map, forKey: storageKey)
    }

    private func canonical(_ s: String) -> String {
        s.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}

