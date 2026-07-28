import SwiftUI

struct AppBackground<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                Color("AppBackground")
                    .overlay {
                        Image("bgBook")
                            .resizable()
                            .scaledToFill()
                            .opacity(colorScheme == .dark ? 0.3 : 0.12)
                    }
                    .clipped()
                    .ignoresSafeArea()
            }
    }
}
