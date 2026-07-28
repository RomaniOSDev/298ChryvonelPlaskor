import SwiftUI

struct BannerHeader: View {
    let title: String
    let subtitle: String?

    init(_ title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image("bannerTimeline")
                .resizable()
                .scaledToFill()
                .frame(height: 140)
                .clipped()
                .overlay(
                    LinearGradient(
                        colors: [
                            Color("AppBackground").opacity(0.15),
                            Color("AppBackground").opacity(0.85)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(.largeTitle, design: .serif))
                    .foregroundStyle(Color("AppTextPrimary"))
                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                GoldDivider()
                    .frame(width: 96)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 140)
    }
}
