import SwiftUI

struct EmptyStateView: View {
    let message: String
    let systemImage: String

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: systemImage)
                .font(.system(size: 52))
                .foregroundStyle(Color("AppPrimary"))
                .shadow(color: Color("AppPrimary").opacity(0.35), radius: 10, y: 2)

            Text(message)
                .font(.system(.title3, design: .serif))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color("AppTextSecondary"))
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
