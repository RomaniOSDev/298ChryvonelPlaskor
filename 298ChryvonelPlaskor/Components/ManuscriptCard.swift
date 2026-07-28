import SwiftUI

struct ManuscriptCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color("AppSurface"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color("AppPrimary").opacity(0.55),
                                        Color("AppAccent").opacity(0.25)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: Color.black.opacity(0.35), radius: 8, x: 0, y: 4)
            )
    }
}
