import SwiftUI

struct StaffBadge: View {
    @AppStorage(StaffAuth.userDefaultsKey) private var isStaff: Bool = false

    var body: some View {
        if isStaff {
            Text("STAFF")
                .font(.caption2).bold()
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule().fill(Color.red.opacity(0.15)) // fond rouge clair
                )
                .overlay(
                    Capsule().stroke(Color.red, lineWidth: 1) // contour rouge
                )
                .foregroundColor(.red) // texte rouge
                .contentShape(Rectangle())
                .onTapGesture(count: 2) {
                    isStaff = false
                    #if os(iOS)
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    #endif
                }
                .accessibilityLabel("Badge STAFF, double-tap pour désactiver")
                // décalage vers la gauche
                .offset(x: -40)
        }
    }
}
