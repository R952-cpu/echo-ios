//
//  PMContentMessage.swift
//  Echo
//
//  Created by Cécile Jaouën on 10/08/2025.
//

import Foundation

/// Message binaire de demande/d’acceptation/refus de MP.
/// Le format binaire est : [version (1 octet)][longueur (UInt16, big‑endian)][fingerprint (UTF‑8)].
public struct PMConsentMessage {
    public static let version: UInt8 = 1
    public let fingerprint: String
    
    public init(fingerprint: String) {
        self.fingerprint = fingerprint
    }

    /// Encode le message au format binaire.
    public func toBinaryData() -> Data {
        var data = Data()
        data.append(Self.version)
        let utf8Data = fingerprint.data(using: .utf8) ?? Data()
        var length = UInt16(utf8Data.count).bigEndian
        withUnsafeBytes(of: &length) { data.append(contentsOf: $0) }
        data.append(utf8Data)
        return data
    }

    /// Décode un message depuis son format binaire.
    /// Retourne `nil` si les données sont invalides (longueur incohérente).
    public static func fromBinaryData(_ data: Data) -> PMConsentMessage? {
        var index = 0
        guard index < data.count else { return nil }
        let versionByte = data[index]
        guard versionByte == Self.version else { return nil }
        index += 1
        
        guard index + MemoryLayout<UInt16>.size <= data.count else { return nil }
        let lengthData = data.subdata(in: index ..< index + MemoryLayout<UInt16>.size)
        index += MemoryLayout<UInt16>.size
        let length = lengthData.withUnsafeBytes { $0.load(as: UInt16.self).bigEndian }
        guard index + Int(length) <= data.count else { return nil }
        
        let fpData = data.subdata(in: index ..< index + Int(length))
        guard let fpString = String(data: fpData, encoding: .utf8) else { return nil }
        
        return PMConsentMessage(fingerprint: fpString)
    }
}
