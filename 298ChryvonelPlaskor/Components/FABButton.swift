import SwiftUI

struct FABButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(Color("AppBackground"))
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color("AppAccent"), Color("AppPrimary")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color("AppPrimary").opacity(0.45), radius: 10, y: 4)
                )
        }
        .buttonStyle(.plain)
    }
}
