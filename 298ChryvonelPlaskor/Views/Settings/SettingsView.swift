import SwiftUI
import StoreKit
import UIKit

struct SettingsView: View {
    @ObservedObject var store: DataStore
    @State private var showResetConfirm = false

    var body: some View {
        AppBackground {
            VStack(spacing: 0) {
                BannerHeader("Settings", subtitle: "Manage your chronicle")

                ScrollView {
                    VStack(spacing: 14) {
                        ManuscriptCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Appearance")
                                    .font(.system(.title3, design: .serif))
                                    .foregroundStyle(Color("AppTextPrimary"))
                                GoldDivider()
                                Picker("Theme", selection: Binding(
                                    get: { store.appearance },
                                    set: { store.setAppearance($0) }
                                )) {
                                    ForEach(AppAppearance.allCases) { mode in
                                        Text(mode.title).tag(mode)
                                    }
                                }
                                .pickerStyle(.segmented)

                                Text("Text size")
                                    .font(.system(.body, design: .serif))
                                    .foregroundStyle(Color("AppTextPrimary"))
                                    .padding(.top, 4)
                                Picker("Text size", selection: Binding(
                                    get: { store.fontSize },
                                    set: { store.setFontSize($0) }
                                )) {
                                    ForEach(AppFontSize.allCases) { size in
                                        Text(size.title).tag(size)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                        }

                        if SoundService.isAvailable || HapticService.isAvailable {
                            ManuscriptCard {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Feedback")
                                        .font(.system(.title3, design: .serif))
                                        .foregroundStyle(Color("AppTextPrimary"))
                                    GoldDivider()

                                    if SoundService.isAvailable {
                                        Toggle(isOn: Binding(
                                            get: { store.soundEnabled },
                                            set: { store.setSoundEnabled($0) }
                                        )) {
                                            Label {
                                                Text("Sound")
                                                    .font(.system(.body, design: .serif))
                                                    .foregroundStyle(Color("AppTextPrimary"))
                                            } icon: {
                                                Image(systemName: "speaker.wave.2.fill")
                                                    .foregroundStyle(Color("AppPrimary"))
                                            }
                                        }
                                        .tint(Color("AppPrimary"))
                                        .onChange(of: store.soundEnabled) { enabled in
                                            if enabled { SoundService.tap() }
                                        }
                                    }

                                    if HapticService.isAvailable {
                                        Toggle(isOn: Binding(
                                            get: { store.hapticEnabled },
                                            set: { store.setHapticEnabled($0) }
                                        )) {
                                            Label {
                                                Text("Haptic Feedback")
                                                    .font(.system(.body, design: .serif))
                                                    .foregroundStyle(Color("AppTextPrimary"))
                                            } icon: {
                                                Image(systemName: "hand.tap.fill")
                                                    .foregroundStyle(Color("AppPrimary"))
                                            }
                                        }
                                        .tint(Color("AppPrimary"))
                                        .onChange(of: store.hapticEnabled) { enabled in
                                            if enabled { HapticService.light() }
                                        }
                                    }
                                }
                            }
                        }

                        settingsRow(title: "Rate Us", icon: "star.fill") {
                            requestReview()
                        }

                        Link(destination: AppLinks.privacy) {
                            settingsRowLabel(title: "Privacy Policy", icon: "hand.raised.fill")
                        }

                        Link(destination: AppLinks.terms) {
                            settingsRowLabel(title: "Terms of Use", icon: "doc.text.fill")
                        }

                        Button {
                            showResetConfirm = true
                            HapticService.warning()
                        } label: {
                            settingsRowLabel(title: "Reset All Data", icon: "trash.fill", destructive: true)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(16)
                    .padding(.bottom, 24)
                }
            }
        }
        .alert("Reset All Data?", isPresented: $showResetConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                store.resetAllData()
            }
        } message: {
            Text("This will permanently delete all events, stats, and achievements.")
        }
    }

    private func requestReview() {
        HapticService.light()
        SoundService.tap()
        if let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) {
            SKStoreReviewController.requestReview(in: scene)
        }
    }

    private func settingsRow(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            settingsRowLabel(title: title, icon: icon)
        }
        .buttonStyle(.plain)
    }

    private func settingsRowLabel(title: String, icon: String, destructive: Bool = false) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(destructive ? Color.red.opacity(0.85) : Color("AppPrimary"))
                .frame(width: 24)
            Text(title)
                .font(.system(.body, design: .serif))
                .foregroundStyle(destructive ? Color.red.opacity(0.9) : Color("AppTextPrimary"))
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(Color("AppTextSecondary"))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color("AppSurface"))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color("AppPrimary").opacity(0.25), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.25), radius: 6, y: 3)
        )
    }
}
