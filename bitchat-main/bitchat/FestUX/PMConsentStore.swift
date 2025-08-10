//
//  PMConsentStore.swift
//  Echo
//
//  Created by Cécile Jaouën on 10/08/2025.
//

import Foundation

enum PMConsentStatus: String {
    case unknown, requested, accepted, refused
}

/// Stocke l’état d’opt-in PM par paire de fingerprints (symétrique)
final class PMConsentStore {
    static let shared = PMConsentStore()

    private let defaults: UserDefaults
    private let namespace = "pmConsent.v1."

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func status(between a: String, and b: String) -> PMConsentStatus {
        let key = keyFor(a, b)
        if let raw = defaults.string(forKey: key),
           let s = PMConsentStatus(rawValue: raw) {
            return s
        }
        return .unknown
    }

    func setStatus(_ status: PMConsentStatus, between a: String, and b: String) {
        defaults.set(status.rawValue, forKey: keyFor(a, b))
    }

    func reset(between a: String, and b: String) {
        defaults.removeObject(forKey: keyFor(a, b))
    }

    // Exemple pratique : depuis des peerID, on résout d’abord les fingerprints
    func statusFromPeerIDs(myPeerID: String, otherPeerID: String) -> PMConsentStatus {
        guard
            let myFP = PeerFingerprintMapper.shared.fingerprint(for: myPeerID),
            let otherFP = PeerFingerprintMapper.shared.fingerprint(for: otherPeerID)
        else { return .unknown }
        return status(between: myFP, and: otherFP)
    }

    private func keyFor(_ a: String, _ b: String) -> String {
        // clé symétrique (min|max) pour que (A,B) == (B,A)
        let (x, y) = a <= b ? (a, b) : (b, a)
        return namespace + x + "|" + y
    }
}
