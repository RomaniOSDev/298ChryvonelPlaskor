import SwiftUI

struct OnboardingView: View {
    let onFinish: (_ seedDemo: Bool) -> Void
    @State private var page = 0
    @State private var seedDemo = true

    private let pages: [(title: String, body: String, image: String)] = [
        (
            "Visualize Story Events",
            "This app helps you create and manage timelines for book events.",
            "bgBook"
        ),
        (
            "Plot Key Events",
            "Tap to add significant events to your timeline as you read.",
            "bannerTimeline"
        ),
        (
            "Start Your First Timeline",
            "Begin with a short sample chronicle, or start with a blank page.",
            "stackBooks"
        )
    ]

    var body: some View {
        AppBackground {
            VStack(spacing: 0) {
                TabView(selection: $page) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        onboardingPage(pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: page)

                VStack(spacing: 16) {
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { i in
                            Capsule()
                                .fill(i == page ? Color("AppPrimary") : Color("AppTextSecondary").opacity(0.35))
                                .frame(width: i == page ? 22 : 7, height: 7)
                                .animation(.easeInOut(duration: 0.25), value: page)
                        }
                    }

                    if page == pages.count - 1 {
                        Toggle(isOn: $seedDemo) {
                            Text("Load sample chronicle")
                                .font(.system(.subheadline, design: .serif))
                                .foregroundStyle(Color("AppTextPrimary"))
                        }
                        .tint(Color("AppPrimary"))
                    }

                    Button {
                        HapticService.medium()
                        SoundService.tap()
                        if page < pages.count - 1 {
                            withAnimation(.easeInOut(duration: 0.3)) { page += 1 }
                        } else {
                            onFinish(seedDemo)
                        }
                    } label: {
                        Text(page < pages.count - 1 ? "Continue" : "Begin")
                            .font(.system(.headline, design: .serif))
                            .foregroundStyle(Color("AppBackground"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(
                                    colors: [Color("AppAccent"), Color("AppPrimary")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(4)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 28)
                .padding(.top, 8)
            }
        }
    }

    private func onboardingPage(_ item: (title: String, body: String, image: String)) -> some View {
        VStack(spacing: 0) {
            Image(item.image)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 320)
                .clipped()
                .overlay(
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color("AppBackground").opacity(0.55),
                            Color("AppBackground")
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            VStack(alignment: .leading, spacing: 16) {
                Text(item.title)
                    .font(.system(.largeTitle, design: .serif).weight(.bold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .fixedSize(horizontal: false, vertical: true)

                GoldDivider()
                    .frame(width: 90)

                Text(item.body)
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(Color("AppTextSecondary"))
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}
