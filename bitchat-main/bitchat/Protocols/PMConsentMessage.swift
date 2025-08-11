import Foundation

/// Represents a peer-to-peer consent message exchanged before private messaging
struct PMConsentMessage: Codable {
    /// Fingerprint associated with the consent request/response
    let fingerprint: String

    /// Create a consent message from raw binary data
    /// - Parameter data: Encoded message payload
    /// - Returns: A valid message or nil if decoding fails
    static func fromBinaryData(_ data: Data) -> PMConsentMessage? {
        do {
            let decoded = try JSONDecoder().decode(PMConsentMessage.self, from: data)
            return decoded
        } catch {
            print("PMConsentMessage: decode error: \(error)")
            return nil
        }
    }
}
