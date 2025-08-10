import Foundation

public struct PMConsentMessage {
    public let fingerprint: String
    public init(fingerprint: String) { self.fingerprint = fingerprint }

    /// Format binaire: [version: UInt8 = 1][len: UInt16 big-endian][UTF8 fingerprint]
    public func toBinaryData() -> Data {
        var data = Data()
        data.appendUInt8(1)
        let fingerprintData = fingerprint.data(using: .utf8) ?? Data()
        data.appendUInt16(UInt16(fingerprintData.count))
        data.append(fingerprintData)
        return data
    }

    public static func fromBinaryData(_ data: Data) -> PMConsentMessage? {
        var offset = 0
        guard let version = data.readUInt8(at: &offset), version == 1 else {
            return nil
        }
        guard let length = data.readUInt16(at: &offset) else {
            return nil
        }
        guard data.count == offset + Int(length) else {
            return nil
        }
        let fpData = data[offset..<(offset + Int(length))]
        guard let fingerprint = String(data: fpData, encoding: .utf8) else {
            return nil
        }
        return PMConsentMessage(fingerprint: fingerprint)
    }
}

