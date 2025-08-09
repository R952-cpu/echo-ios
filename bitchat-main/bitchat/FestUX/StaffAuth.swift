//
//  Untitled.swift
//  bitchat
//
//  Created by Cécile Jaouën on 09/08/2025.
//
import Foundation

enum StaffAuth {
    static let userDefaultsKey = "festival.isStaff"
    static let code = "ECHObeta"
    
    static var isStaff: Bool {
        get { UserDefaults.standard.bool(forKey: userDefaultsKey) }
        set { UserDefaults.standard.set(newValue, forKey: userDefaultsKey) }
    }
    
    @discardableResult
    static func activate(with input: String) -> Bool {
        let ok = input.trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased() == code.lowercased()
        if ok { isStaff = true }
        return ok
    }
    
    static func deactivate() {
        isStaff = false
    }
}

