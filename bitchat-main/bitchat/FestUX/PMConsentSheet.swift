//
//  PMConsentSheet.swift
//  Echo
//
//  Created by Cécile Jaouën on 10/08/2025.
//

import SwiftUI

struct PMConsentSheet: View {
    @Environment(\.dismiss) private var dismiss

    let fromNickname: String
    let onAccept: () -> Void
    let onDecline: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            Text("Autoriser le message privé de \(fromNickname) ?")
                .font(.headline)
                .multilineTextAlignment(.center)

            Text("Si vous acceptez, vous pourrez échanger en direct. Sinon, cette demande sera ignorée.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 12) {
                Button(role: .cancel) {
                    onDecline()
                    dismiss()
                } label: {
                    Text("Refuser").frame(maxWidth: .infinity)
                }

                Button {
                    onAccept()
                    dismiss()
                } label: {
                    Text("Accepter").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(20)
        .presentationDetents([.fraction(0.32)])
    }
}
