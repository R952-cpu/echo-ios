import Foundation

/// Maintains bidirectional mappings between ephemeral peer IDs and stable fingerprints.
/// Provides thread-safe access across the application.
final class PeerFingerprintMapper {
    static let shared = PeerFingerprintMapper()

    private var peerIDToFingerprint: [String: String] = [:]
    private var fingerprintToPeerID: [String: String] = [:]
    private let queue = DispatchQueue(label: "chat.bitchat.peerFingerprintMapper", attributes: .concurrent)

    private init() {}

    /// Associates a peer ID with a fingerprint.
    func setFingerprint(_ fingerprint: String, for peerID: String) {
        queue.async(flags: .barrier) {
            self.peerIDToFingerprint[peerID] = fingerprint
            self.fingerprintToPeerID[fingerprint] = peerID
        }
    }

    /// Retrieves the fingerprint for a peer ID.
    func fingerprint(for peerID: String) -> String? {
        queue.sync {
            peerIDToFingerprint[peerID]
        }
    }

    /// Retrieves the current peer ID for a fingerprint.
    func peerID(for fingerprint: String) -> String? {
        queue.sync {
            fingerprintToPeerID[fingerprint]
        }
    }

    /// Removes all mappings for a peer ID.
    func removePeerID(_ peerID: String) {
        queue.async(flags: .barrier) {
            if let fingerprint = self.peerIDToFingerprint.removeValue(forKey: peerID) {
                self.fingerprintToPeerID.removeValue(forKey: fingerprint)
            }
        }
    }
}

