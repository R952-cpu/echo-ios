import Foundation

/// Extension handling PM consent-related messages
extension BluetoothMeshService {
    /// Handle an incoming PM consent message
    /// - Parameters:
    ///   - type: The consent message type
    ///   - peerID: The sender peer identifier
    ///   - payload: Raw message payload
    func handlePMConsentMessage(type: PMConsentMessageType, from peerID: String, payload: Data) {
        print("Service: handlePMConsentMessage \(type) from \(peerID) — bytes=\(payload.count)")

        guard let msg = PMConsentMessage.fromBinaryData(payload) else {
            print("Service: PMConsentMessage decode FAILED for \(type) from \(peerID)")
            return
        }

        if msg.fingerprint.isEmpty {
            print("Service: PMConsentMessage missing fingerprint for \(type) from \(peerID) — dropping")
            return
        }

        print("Service: PMConsentMessage decode OK — fp=\(msg.fingerprint)")
        print("Service: calling delegate.didReceivePMConsent \(type) for \(peerID)")
        delegate?.didReceivePMConsent(msg, from: peerID, type: type)
    }
}

/// PM consent message types supported by the mesh service
enum PMConsentMessageType {
    case request
    case accept
    case refuse
}
