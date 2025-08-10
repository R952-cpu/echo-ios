import Foundation

final class PeerFingerprintMapper {
    static let shared = PeerFingerprintMapper()

    private var map: [String: String] = [:]
    private let queue = DispatchQueue(label: "echo.peerFingerprintMapper", attributes: .concurrent)

    private init() {}

    // Nom attendu par SecureIdentityStateManager
    func setFingerprint(peerID: String, fingerprint: String) {
        setMapping(peerID: peerID, fingerprint: fingerprint)
    }

    // Nom attendu par SecureIdentityStateManager
    func removePeerID(_ peerID: String) {
        remove(peerID: peerID)
    }

    // Nom interne plus explicite
    func setMapping(peerID: String, fingerprint: String) {
        guard !peerID.isEmpty, !fingerprint.isEmpty else { return }
        queue.async(flags: .barrier) {
            self.map[peerID] = fingerprint
        }
    }

    func fingerprint(for peerID: String) -> String? {
        queue.sync { map[peerID] }
    }

    func remove(peerID: String) {
        guard !peerID.isEmpty else { return }
        queue.async(flags: .barrier) {
            self.map.removeValue(forKey: peerID)
        }
    }

    func resetAll() {
        queue.async(flags: .barrier) {
            self.map.removeAll()
        }
    }
}
