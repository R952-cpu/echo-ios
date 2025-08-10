import Foundation

extension BluetoothMeshService {

    // MARK: - Send

    func sendPMConsent(_ action: PMConsentAction, to peerID: String) {
        // Fingerprint local via ton service Noise
        let myFingerprint = getNoiseService().getIdentityFingerprint()

        // Encode le message PM
        let msg = PMConsentMessage(fingerprint: myFingerprint)
        let payload = msg.toBinaryData()

        // Type protocole selon l'action
        let type: MessageType = {
            switch action {
            case .request: return .pmRequest
            case .accept:  return .pmAccept
            case .refuse:  return .pmRefuse
            }
        }()

        // Construit le paquet (init complet aligné avec ton BitchatPacket)
        let packet = BitchatPacket(
            type: type.rawValue,
            senderID: Data(hexString: myPeerID) ?? Data(),
            recipientID: Data(hexString: peerID) ?? Data(),
            timestamp: UInt64(Date().timeIntervalSince1970 * 1000),
            payload: payload,
            signature: nil,
            ttl: 6
        )

        // Envoi direct P2P (API existante chez toi)
        _ = sendDirectToRecipient(packet, recipientPeerID: peerID)
    }

    // MARK: - Receive

    func handlePMConsentMessage(_ type: PMConsentAction, from peerID: String, payload: Data) {
        guard let msg = PMConsentMessage.fromBinaryData(payload) else { return }
        delegate?.didReceivePMConsent(msg, from: peerID, type: type)
    }
}
