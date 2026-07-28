import SwiftUI

struct AchievementBannerOverlay: View {
    let achievement: AchievementID
    let onDismiss: () -> Void

    var body: some View {
        VStack {
            HStack(spacing: 12) {
                Image(systemName: achievement.iconName)
                    .font(.title2)
                    .foregroundStyle(Color("AppBackground"))
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color("AppPrimary")))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Achievement Unlocked")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                    Text(achievement.title)
                        .font(.system(.headline, design: .serif))
                        .foregroundStyle(Color("AppTextPrimary"))
                }
                Spacer()
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color("AppSurface"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color("AppPrimary"), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.4), radius: 12, y: 6)
            )
            .padding(.horizontal, 16)
            .padding(.top, 8)
            Spacer()
        }
        .transition(.move(edge: .top).combined(with: .opacity))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
                withAnimation { onDismiss() }
            }
        }
        .onTapGesture {
            withAnimation { onDismiss() }
        }
    }
}
