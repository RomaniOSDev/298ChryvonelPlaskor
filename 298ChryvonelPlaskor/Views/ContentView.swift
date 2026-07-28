import SwiftUI

struct ContentView: View {
    @ObservedObject private var store = DataStore.shared

    var body: some View {
        Group {
            if store.hasCompletedOnboarding {
                MainTabView(store: store)
            } else {
                OnboardingView { seedDemo in
                    store.completeOnboarding(seedDemo: seedDemo)
                }
            }
        }
        .preferredColorScheme(store.appearance.colorScheme)
        .environment(\.sizeCategory, store.fontSize.sizeCategory)
        .onAppear {
            if store.hasCompletedOnboarding {
                store.registerSession()
            }
        }
    }
}
