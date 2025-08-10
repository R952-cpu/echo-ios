import Foundation

extension BluetoothMeshService {
    func sendPMConsent(_ action: PMConsentAction, to peerID: String) {
        let fingerprint = getNoiseService().getIdentityFingerprint()
        let message = PMConsentMessage(fingerprint: fingerprint)
        let payload = message.toBinaryData()
        let type: MessageType
        switch action {
        case .request: type = .pmRequest
        case .accept: type = .pmAccept
        case .refuse: type = .pmRefuse
        }
        let packet = BitchatPacket(
            type: type.rawValue,
            senderID: Data(hexString: myPeerID) ?? Data(),
            recipientID: Data(hexString: peerID) ?? Data(),
            timestamp: UInt64(Date().timeIntervalSince1970 * 1000),
            payload: payload,
            signature: nil,
            ttl: 6
        )
        _ = sendDirectToRecipient(packet, recipientPeerID: peerID)
    }

    func handlePMConsentMessage(_ type: PMConsentAction, from peerID: String, payload: Data) {
        guard let msg = PMConsentMessage.fromBinaryData(payload) else { return }
        delegate?.didReceivePMConsent(msg, from: peerID, type: type)
    }
}

