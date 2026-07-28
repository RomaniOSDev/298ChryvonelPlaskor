import SwiftUI

enum AppTab: Int, CaseIterable, Identifiable {
    case timeline
    case library
    case stats
    case achievements
    case settings

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .timeline: return "Timeline"
        case .library: return "Library"
        case .stats: return "Stats"
        case .achievements: return "Badges"
        case .settings: return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .timeline: return "scroll"
        case .library: return "books.vertical"
        case .stats: return "chart.bar"
        case .achievements: return "rosette"
        case .settings: return "gearshape"
        }
    }
}

struct LiteraryTabBar: View {
    @Binding var selection: AppTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                Button {
                    selection = tab
                    HapticService.light()
                    SoundService.tap()
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 16, weight: selection == tab ? .semibold : .regular))
                        Text(tab.title)
                            .font(.system(size: 9, weight: .medium, design: .serif))
                        Capsule()
                            .fill(selection == tab ? Color("AppPrimary") : Color.clear)
                            .frame(width: 18, height: 2)
                    }
                    .foregroundStyle(selection == tab ? Color("AppPrimary") : Color("AppTextSecondary"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
        .background(
            Rectangle()
                .fill(Color("AppSurface").opacity(0.95))
                .overlay(alignment: .top) {
                    GoldDivider()
                }
                .shadow(color: Color.black.opacity(0.35), radius: 8, y: -2)
                .ignoresSafeArea(edges: .bottom)
        )
    }
}
