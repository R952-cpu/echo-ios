//
//  PrivatechatState.swift
//  Echo
//
//  Created by Cécile Jaouën on 11/08/2025.
//

// Models/PrivateChatState.swift
import Foundation

/// États d’un chat privé.
public enum PrivateChatState {
    case none             // aucune demande
    case requestSent      // demande envoyée, en attente de réponse
    case requestReceived  // demande reçue, en attente de notre décision
    case active           // chat accepté des deux côtés
    case rejected         // demande refusée
}
