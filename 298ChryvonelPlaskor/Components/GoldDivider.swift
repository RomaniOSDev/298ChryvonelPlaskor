import SwiftUI

struct GoldDivider: View {
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        Color("AppPrimary").opacity(0.15),
                        Color("AppPrimary"),
                        Color("AppAccent"),
                        Color("AppPrimary").opacity(0.15)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 1.5)
    }
}
