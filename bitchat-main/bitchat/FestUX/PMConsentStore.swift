//
//  PMConsentStore.swift
//  Echo
//
//  Created by Cécile Jaouën on 10/08/2025.
//

import Foundation

/// Persiste l'accord/refus de PM par *fingerprint stable*.
/// Thread-safe (concurrent queue + barrier) et persistance UserDefaults (suite dédiée).
public final class PMConsentStore {

    public static let shared = PMConsentStore()

    // Utilise une suite dédiée pour éviter les collisions de clés.
    private let defaults: UserDefaults
    private let storageKey = "pm.consent.v1"       // JSON-encodé
    private let queue = DispatchQueue(label: "io.echo.pmconsent.store", attributes: .concurrent)

    private struct Snapshot: Codable {
        var accepted: Set<String>   // fingerprints autorisés
        var blocked: Set<String>    // fingerprints bloqués (optionnel)
    }

    // État mémoire (protégé par queue)
    private var accepted: Set<String> = []
    private var blocked: Set<String> = []

    // MARK: - Init

    public init(suiteName: String = "io.echo.pmconsent") {
        self.defaults = UserDefaults(suiteName: suiteName) ?? .standard
        load()
    }

    // MARK: - Public API (fingerprint-first)

    public func isAccepted(fingerprint: String) -> Bool {
        let k = canonical(fingerprint)
        var ok = false
        queue.sync { ok = accepted.contains(k) }
        return ok
    }

    public func accept(fingerprint: String) {
        let k = canonical(fingerprint)
        queue.async(flags: .barrier) {
            self.blocked.remove(k)
            self.accepted.insert(k)
            self.save()
        }
    }

    public func revoke(fingerprint: String) {
        let k = canonical(fingerprint)
        queue.async(flags: .barrier) {
            self.accepted.remove(k)
            self.save()
        }
    }

    // Blocage dur (optionnel)
    public func isBlocked(fingerprint: String) -> Bool {
        let k = canonical(fingerprint)
        var ok = false
        queue.sync { ok = blocked.contains(k) }
        return ok
    }

    public func block(fingerprint: String) {
        let k = canonical(fingerprint)
        queue.async(flags: .barrier) {
            self.accepted.remove(k)
            self.blocked.insert(k)
            self.save()
        }
    }

    public func unblock(fingerprint: String) {
        let k = canonical(fingerprint)
        queue.async(flags: .barrier) {
            self.blocked.remove(k)
            self.save()
        }
    }

    // MARK: - Helpers (interop future avec PeerFingerprintMapper)

    /// Convenience si tu n'as que le peerID : tu injecteras plus tard un mapper.
    public func accept(peerID: String, using mapper: (String) -> String?) {
        if let fp = mapper(peerID) { accept(fingerprint: fp) }
    }
    public func revoke(peerID: String, using mapper: (String) -> String?) {
        if let fp = mapper(peerID) { revoke(fingerprint: fp) }
    }
    public func isAccepted(peerID: String, using mapper: (String) -> String?) -> Bool {
        guard let fp = mapper(peerID) else { return false }
        return isAccepted(fingerprint: fp)
    }
    public func block(peerID: String, using mapper: (String) -> String?) {
        if let fp = mapper(peerID) { block(fingerprint: fp) }
    }
    public func unblock(peerID: String, using mapper: (String) -> String?) {
        if let fp = mapper(peerID) { unblock(fingerprint: fp) }
    }
    public func isBlocked(peerID: String, using mapper: (String) -> String?) -> Bool {
        guard let fp = mapper(peerID) else { return false }
        return isBlocked(fingerprint: fp)
    }

    // MARK: - Storage

    private func canonical(_ s: String) -> String {
        s.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private func load() {
        guard let data = defaults.data(forKey: storageKey) else { return }
        guard let snap = try? JSONDecoder().decode(Snapshot.self, from: data) else { return }
        accepted = snap.accepted
        blocked  = snap.blocked
    }

    private func save() {
        let snap = Snapshot(accepted: accepted, blocked: blocked)
        guard let data = try? JSONEncoder().encode(snap) else { return }
        defaults.set(data, forKey: storageKey)
    }
}
