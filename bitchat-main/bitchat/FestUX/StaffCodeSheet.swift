//
//  StaffCodeSheet.swift
//  bitchat
//
//  Created by Cécile Jaouën on 09/08/2025.
//
import SwiftUI

struct StaffCodeSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var code = ""
    @State private var error: String?

    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                SecureField("Code STAFF", text: $code)
                    .textContentType(.oneTimeCode)
                    .keyboardType(.asciiCapable)
                    .textFieldStyle(.roundedBorder)

                if let e = error {
                    Text(e)
                        .foregroundColor(.red)
                        .font(.footnote)
                }

                Button("Activer") {
                    if StaffAuth.activate(with: code) {
                        dismiss()
                    } else {
                        error = "Code invalide"
                    }
                }
                .buttonStyle(.borderedProminent)

                Button("Annuler") {
                    dismiss()
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .navigationTitle("Accès STAFF")
        }
    }
}

